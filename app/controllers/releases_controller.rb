class ReleasesController < ApplicationController
  self.default_order = "artists.name, releases.title"

  belongs_to :artist, optional: true
  belongs_to :release, optional: true
  belongs_to :collection, optional: true

  scope { |s| s.duplicate(params.fetch(:duplicate, false)) }
  scope { |s| s.joins(:artist).includes(:collections) }

  def show
    super do |format|
      format.json
      format.mp3 do
        response.headers['Accept-Ranges'] = "bytes"
        resource.increment!(:play_count)
        send_file Track.find(params[:id]).path
      end
    end
  end

  def lookup
    Release.find_each { |release| Jobist.push(LastFMReleaseLookupService.new(release)) }
    render nothing: true, status: :accepted
  end

  protected

  def filter(scope, value)
    scope.where(Release.arel_table[:title].matches("%#{value}%").or(Artist.arel_table[:name].matches("%#{value}%")))
  end

  def permitted_params
    params.permit(release: {collection_ids: []})
  end
end
