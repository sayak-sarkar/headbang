class ApplicationController < ActionController::Base
  module Scoping
    extend ActiveSupport::Concern

    private

    def apply_scopes(target)
      __scopes.each do |scope|
        target = apply_scope(target, scope)
      end
      target
    end

    def apply_scope(target, scope)
      if scope.respond_to?(:call)
        instance_exec(target, &scope) || target
      else
        target.send(scope)
      end
    end

    def __scopes
      @__scopes ||= []
    end

    module ClassMethods
      def scope(*args, &block)
        if block_given?
          before_filter(*args) { __scopes << block }
        else
          opts = args.extract_options!
          before_filter(opts) { __scopes << args.first }
        end
      end
    end
  end

  inherit_resources
  include Scoping
  class_attribute :default_order

  respond_to :json

  scope { |s| s.limit(params.fetch(:limit, 50)) }
  scope { |s| s.offset(params[:offset]) if params[:offset] }
  scope { |s| s.order(params.fetch(:order, self.class.default_order)) }

  scope(only: :index) do |s|
    filter(s, params[:filter]) if params[:filter]
  end
end
