require 'thread'

module Jobist

  class << self
    def [](name)
      self.queues[name] or raise "Unregistered queue: #{name}"
    end

    def push(job)
      self[job.queue].push(job)
    end

    def start
      self.queues.each do |_, queue|
        queue.consumers.each(&:start)
      end
    end

    def shutdown
      self.queues.each do |_, queue|
        queue.consumers.each(&:shutdown)
      end
    end

    def queue(name, options = {})
      self.queues[name] and raise "Queue already defined: #{name}"
      self.queues[name] = Queue.new(options)
    end

    def queues
      @queues ||= {}
    end

    def configure(start = true, &block)
      instance_eval(&block)
      self.start if start
      self.queues.each do |_, queue|
        at_exit { queue.consumers.each(&:shutdown) }
      end
    end
  end

  module Job
    extend ActiveSupport::Concern
    included { class_attribute :queue }
  end

  class Throttler
    def initialize(count, time_span)
      @count, @time_span = count, time_span.to_i
      @mutex = Mutex.new
      @condition = ConditionVariable.new
      @timestamps = [@count, (Time.now - @time_span)]
    end

    def wait
      @mutex.synchronize do
        delta = Time.now - @timestamps.first
        if delta.to_i < @time_span
          @condition.wait(@mutex)
        end
        @timestamps.push(Time.now).shift
      end
    end

    def continue
      @mutex.synchronize { @condition.signal }
    end
  end

  class Queue < ::Queue
    attr_reader :throttler

    def initialize(options = {})
      super()
      @options = options
    end

    def consumers
      @consumers ||= @options.fetch(:consumers, 5).times.map { Consumer.new(self, @options) }
    end

    def throttle(&block)
      throttler.wait if throttler
      block.call
    ensure
      throttler.continue if throttler
    end

    def throttler
      @throttler ||= begin
        if @options.key?(:throttle)
          Throttler.new(*@options[:throttle].first)
        else
          false
        end
      end
    end

    def drain
      consumers.each(&:drain)
    end
  end

  class Consumer
    attr_accessor :logger

    def initialize(queue, options = {})
      @queue = queue
      @logger = options.fetch(:logger, Logger.new($stderr))
    end

    def start
      @thread = Thread.new { consume }
      self
    end

    def shutdown
      @queue.push(nil)
      @thread.join
    end

    def drain
      @queue.pop.run until @queue.empty?
    end

    def consume
      while (job = @queue.pop)
        @queue.throttle { run(job) }
      end
    end

    def run(job)
      job.call
    rescue Exception => exception
      handle_exception job, exception
    end

    def handle_exception(job, exception)
      logger.error "Job Error: #{job.inspect}\n#{exception.message}\n#{exception.backtrace.join("\n")}"
    end
  end
end
