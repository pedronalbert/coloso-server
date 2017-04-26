module V1
  class SummonersController < ApplicationController
    def findByName
      region = params[:region]
      summonerName = params[:summonerName]


      begin
        summoner = RiotApi.getSummonerByName(summonerName, region)
        return render(json: summoner)
      rescue RiotLimitReached
        return render(json: { :message => I18n.t('riot_limit_error') }, status: :service_unavailable)
      rescue EntityNotFoundError
        return render(json: { :message => I18n.t('summoner_not_found') }, status: :not_found)
      rescue
        return render(json: { :message => I18n.t('riot_server_error') }, status: :service_unavailable)
      end
    end

    def findById
      sumUrid = params[:sumUrid]


      begin
        summoner = RiotApi.getSummonerById(sumUrid)
        return render(json: summoner)
      rescue RiotLimitReached
        return render(json: { :message => I18n.t('riot_limit_error') }, status: :service_unavailable)
      rescue EntityNotFoundError
        return render(json: { :message => I18n.t('summoner_not_found') }, status: :not_found)
      rescue
        return render(json: { :message => I18n.t('riot_server_error') }, status: :service_unavailable)
      end
    end

    def runes
      sumUrid = params[:sumUrid]

      begin
        runes = RiotApi.getSummonerRunes(sumUrid)
        return render(json: runes)
      rescue RiotLimitReached
        return render(json: { :message => I18n.t('riot_limit_error') }, status: :service_unavailable)
      rescue EntityNotFoundError
        return render(json: { :message => I18n.t('runes_not_found') }, status: :not_found)
      rescue
        return render(json: { :message => I18n.t('riot_server_error') }, status: :service_unavailable)
      end
    end

    def masteries
      sumUrid = params[:sumUrid]


      begin
        masteries = RiotApi.getSummonerMasteries(sumUrid)
        return render(json: masteries)
      rescue RiotLimitReached
        return render(json: { :message => I18n.t('riot_limit_error') }, status: :service_unavailable)
      rescue EntityNotFoundError
        return render(json: { :message => I18n.t('masteries_not_found') }, status: :not_found)
      rescue
        return render(json: { :message => I18n.t('riot_server_error') }, status: :service_unavailable)
      end
    end

    def championsMastery
      sumUrid = params[:sumUrid]


      begin
        masteries = RiotApi.getSummonerChampionsMastery(sumUrid)
        return render(json: masteries)
      rescue RiotLimitReached
        return render(json: { :message => I18n.t('riot_limit_error') }, status: :service_unavailable)
      rescue
        return render(json: { :message => I18n.t('riot_server_error') }, status: :service_unavailable)
      end
    end

    def statsSummary
      sumUrid = params[:sumUrid]
      season = params[:season]


      begin
        stats = RiotApi.getSummonerStatsSummary(sumUrid, season)
        return render(json: stats)
      rescue RiotLimitReached
        return render(json: { :message => I18n.t('riot_limit_error') }, status: :service_unavailable)
      rescue
        return render(json: { :message => I18n.t('riot_server_error') }, status: :service_unavailable)
      end
    end

    def leagueEntry
      sumUrid = params[:sumUrid]

      begin
        leagueEntry = RiotApi.getSummonerLeagueEntry(sumUrid)
        return render(json: leagueEntry)
      rescue RiotLimitReached
        return render(json: { :message => I18n.t('riot_limit_error') }, status: :service_unavailable)
      rescue
        return render(json: { :message => I18n.t('riot_server_error') }, status: :service_unavailable)
      end
    end

    def gamesRecent
      sumUrid = params[:sumUrid]


      begin
        games = RiotApi.getSummonerGamesRecent(sumUrid)
        return render(json: games)
      rescue RiotLimitReached
        return render(json: { :message => I18n.t('riot_limit_error') }, status: :service_unavailable)
      rescue
        return render(json: { :message => I18n.t('riot_server_error') }, status: :service_unavailable)
      end
    end

    def gameCurrent
      sumUrid = params[:sumUrid]


      begin
        gameCurrent = RiotApi.getSummonerGameCurrent(sumUrid)

        return render(json: gameCurrent )
      rescue RiotLimitReached
        return render(json: { :message => I18n.t('riot_limit_error') }, status: :service_unavailable)
      rescue EntityNotFoundError
        return render(json: { :message => I18n.t('summoner_not_in_game') }, status: :not_found)
      #rescue Exception
      #  return render(json: { :message => I18n.t('riot_server_error') }, status: :service_unavailable)
      end
    end
  end
end
