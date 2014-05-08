class ArtistsController < ApplicationController
  self.default_order = "name"

  def filter(scope, value)
    scope.where(Artist.arel_table[:name].matches("%#{value}%"))
  end
end
