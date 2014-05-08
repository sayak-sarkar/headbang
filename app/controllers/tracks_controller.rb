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
        response.headers['Accept-Ranges'] = "bytes"
        send_file resource.path
      end
    end
  end
end
