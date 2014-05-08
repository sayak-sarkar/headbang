class ReleaseSerializer < ActiveModel::Serializer
  attributes :id, :title, :tracks_count, :artwork_url, :collection_ids,   :year, :path, :name

  has_one :artist, :release

  def name
    File.basename(path)
  end
end
