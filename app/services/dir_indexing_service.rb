class DirIndexingService
  include Jobist::Job
  self.queue = :index

  def initialize(path)
    @path = path
  end

  def call
    Dir.glob(File.join(@path, "**", "*.mp3"), File::FNM_CASEFOLD) do |path|
      Jobist.push(TrackIndexService.new(path))
    end
  end
end
