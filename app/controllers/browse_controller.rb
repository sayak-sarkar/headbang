class BrowseController < ActionController::Base
  respond_to :json

  def index
    respond_with(Dir.glob(File.join(path, "*"), File::FNM_DOTMATCH), each_serializer: BrowseItemSerializer)
  end

  protected

  def path
    @path ||= params.fetch(:path, "/")
  end
end
