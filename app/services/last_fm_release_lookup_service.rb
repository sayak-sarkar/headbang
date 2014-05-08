class LastFMReleaseLookupService
  include Jobist::Job
  self.queue = :last_fm

  def initialize(release)
    @release = release
  end

  def call
    ActiveRecord::Base.connection_pool.with_connection do
      args = {artist: clean(@release.artist.name), album: clean(@release.title)}
      puts "LastFM: #{args.inspect}"
      response = LastFM::Album.search(args)
      response.album && response.album.tap do |result|
        @release.artist.update_attributes(name: result.artist)
        @release.update_attributes(release_attributes(result))
      end
    end
  end

  def clean(value)
    Headbang::STOP_WORDS.reduce(value.downcase.gsub(/[^a-z0-9]+/, ' ').gsub(/\s+/, ' ')) { |ret, word| ret.gsub(/\b#{word}\b/, '') }.strip
  end

  def release_attributes(result)
    {
        title: result.name,
        music_brainz_id: result.mbid,
        last_fm_id: result.id,
        last_fm_url: result.url,
        artwork_url: artwork_url(result),
        released_at: released_at(result),
        year: released_at(result).try(:year)
    }
  end

  def released_at(album)
    Date.parse(album["releasedate"].strip)
  rescue
    nil
  end

  def artwork_url(album)
    album.image.each_with_object({}) { |image, h| h[image["size"]] = image["#text"] }["extralarge"]
  end
end
