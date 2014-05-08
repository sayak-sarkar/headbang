class TrackSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  attributes :id, :number, :title, :release_title, :release_id, :artist_name, :artist_id, :length, :bitrate, :src, :type

  def src
    track_url(object, format: "mp3")
  end

  def type
    # TODO: Remove after implementing
    "audio/mp3"
  end
end
