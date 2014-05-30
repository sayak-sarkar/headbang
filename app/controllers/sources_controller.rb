class SourcesController < ApplicationController
  self.default_order = "created_at"

  def permitted_params
    params.permit(source: :path)
  end
end
