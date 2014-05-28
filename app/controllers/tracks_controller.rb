class TracksController < ApplicationController
  belongs_to :release, optional: true
  scope { |s| s.includes(:release).includes(:artist).order("number") }

  def show
    super do |format|
      format.json
      format.mp3 do
        resource.increment!(:play_count)
        resource.release.increment!(:play_count)
        resource.artist.increment!(:play_count)

        stream_file(resource.path)
      end
    end
  end

  protected

  def stream_file(path)
    size = File.size(path)
    if range = Rack::Utils.byte_ranges(request.headers, size).first
      offset = range.begin
      length = range.end - range.begin + 1

      response.header["Accept-Ranges"] = "bytes"
      response.header["Content-Range"] = "bytes #{range.begin}-#{range.end}/#{size}"

      send_data IO.binread(path, length, offset), stream: true, status: 206
    else
      render status: 416
    end
  end
end
