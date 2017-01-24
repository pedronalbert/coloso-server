def pagination_dict(object)
  {
    currentPage: object.current_page,
    totalPages: object.total_pages,
  }
end

class ProBuildsController < ApplicationController
  def index
    query = ProBuild
    pageNumber = params[:page] && params[:page]['number'] || 1
    pageSize = params[:page] && params[:page]['size'] || 25

    if params[:championId]
      query = query.where(championId: params[:championId].to_i)
    end

    if params[:proPlayerId]
      proSummoner = ProSummoner.find_by(pro_player_id: params[:proPlayerId].to_i)

      if proSummoner
        query = query.where(pro_summoner_id: proSummoner.id)
      end
    end

    proBuilds = query.includes(:pro_summoner => :pro_player).paginate(:page => pageNumber, :per_page => pageSize).order('matchCreation DESC')

    return render json: proBuilds, meta: pagination_dict(proBuilds), include: '**'
  end

  def show
    proBuild = ProBuild.includes(:pro_summoner => :pro_player).find_by(id: params[:id])

    if proBuild
      return render json: proBuild, include: '**'
    else
      return render(json: { :message => I18n.t('build_not_found') }, status: :not_found )
    end

  end
end