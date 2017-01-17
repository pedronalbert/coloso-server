# TODO: Add riot server error
class SummonersController < ApplicationController
  def findByName
    region = params[:region]
    summonerName = params[:summonerName]

    riotApi = RiotApi.new(region)

    begin
      summoner = riotApi.getSummonerByName(summonerName)
      return render(json: summoner)
    rescue RiotLimitReached
      return render(json: { :message => I18n.t('riot_limit_error') })
    rescue EntityNotFoundError
      return render(json: { :message => I18n.t('summoner_not_found') })
    end
  end

  def findById
    region = params[:region]
    summonerId = params[:summonerId]

    riotApi = RiotApi.new(region)

    begin
      summoner = riotApi.getSummonerById(summonerId)
      return render(json: summoner)
    rescue RiotLimitReached
      return render(json: { :message => I18n.t('riot_limit_error') })
    rescue EntityNotFoundError
      return render(json: { :message => I18n.t('summoner_not_found') })
    end
  end

  def runes
    region = params[:region]
    summonerId = params[:summonerId]

    riotApi = RiotApi.new(region)

    begin
      runes = riotApi.getSummonerRunes(summonerId)
      return render(json: runes)
    rescue RiotLimitReached
      return render(json: { :message => I18n.t('riot_limit_error') })
    rescue EntityNotFoundError
      return render(json: { :message => I18n.t('runes_not_found') })
    end
  end

  def masteries
    region = params[:region]
    summonerId = params[:summonerId]

    riotApi = RiotApi.new(region)

    begin
      masteries = riotApi.getSummonerMasteries(summonerId)
      return render(json: masteries)
    rescue RiotLimitReached
      return render(json: { :message => I18n.t('riot_limit_error') })
    rescue EntityNotFoundError
      return render(json: { :message => I18n.t('masteries_not_found') })
    end
  end

  def championsMastery
    region = params[:region]
    summonerId = params[:summonerId]

    riotApi = RiotApi.new(region)

    begin
      masteries = riotApi.getSummonerChampionsMastery(summonerId)
      return render(json: masteries)
    rescue RiotLimitReached
      return render(json: { :message => I18n.t('riot_limit_error') })
    end
  end
end
