class SkillsController < ApplicationController
  respond_to :json

  def index
    if params[:q].blank?
      head :not_found and return
    end

    query_str = params[:q]

    tags_found = Tag.search_by_name_alike(query_str)

    if tags_found.empty?
      head :not_found and return
    end

    render json: tags_found.pluck(:name)

  end
end

