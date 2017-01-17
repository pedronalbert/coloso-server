require 'http'

API_KEY = ENV['RIOT_API_KEY']

def regionToPlatform(region)
  if region == 'br'
    return 'br1'
  elsif region == 'eune'
    return 'eun1'
  elsif region == 'euw'
    return 'euw1'
  elsif region == 'jp'
    return 'jp1'
  elsif region == 'kr'
    return 'kr'
  elsif region == 'lan'
    return 'la1'
  elsif region == 'las'
    return 'la2'
  elsif region == 'na'
    return 'na1'
  elsif region == 'oce'
    return 'oc1'
  elsif region == 'ru'
    return 'ru'
  end
end

class RiotClient
  def initialize(region)
    @region = region
  end

  def fetchSummonerByName(sumName)
    url = "https://#{@region}.api.pvp.net/api/lol/#{@region}/v1.4/summoner/by-name/#{sumName}"
    response = HTTP.get(url, :params => { :api_key => API_KEY })

    if response.code == 200
      jsonData = response.parse.values[0]

      return {
        :summonerId => jsonData['id'],
        :name => jsonData['name'],
        :summonerLevel => jsonData['summonerLevel'],
        :profileIconId => jsonData['profileIconId'],
        :region => @region,
      }

    elsif response.code == 404
      raise EntityNotFoundError
    elsif response.code == 429
      raise RiotLimitReached
    else
      raise RiotServerError
    end
  end

  def fetchSummonerById(sumId)
    url = "https://#{@region}.api.pvp.net/api/lol/#{@region}/v1.4/summoner/#{sumId}"
    response = HTTP.get(url, :params => { :api_key => API_KEY })

    if response.code == 200
      jsonData = response.parse.values[0]

      return {
        :summonerId => jsonData['id'],
        :name => jsonData['name'],
        :summonerLevel => jsonData['summonerLevel'],
        :profileIconId => jsonData['profileIconId'],
        :region => @region,
      }

    elsif response.code == 404
      raise EntityNotFoundError
    elsif response.code == 429
      raise RiotLimitReached
    else
      raise RiotServerError
    end
  end

  def fetchSummonerRunes(sumId)
    url = "https://#{@region}.api.pvp.net/api/lol/#{@region}/v1.4/summoner/#{sumId}/runes"
    response = HTTP.get(url, :params => { :api_key => API_KEY })

    if response.code == 200
      jsonData = response.parse.values[0]
      groupPages = []

      jsonData['pages'].each do |page|
        groupRunes = []

        page['slots'].each do |slot|
          runeIndexInGrouped = groupRunes.index{|groupRune| groupRune[:runeId] == slot['runeId']}

          if runeIndexInGrouped != nil
            groupRunes[runeIndexInGrouped][:count] += 1
          else
            groupRunes.push({
                :runeId => slot['runeId'],
                :count => 1
            })
          end

          groupPages.push({
              :id => page['id'],
              :name => page['name'],
              :current => page['current'],
              :runes => groupRunes,
          })
        end
      end

      return {
        :summonerId => jsonData['summonerId'],
        :pages => groupPages,
        :region => @region,
      }

    elsif response.code == 404
      raise EntityNotFoundError
    elsif response.code == 429
      raise RiotLimitReached
    else
      raise RiotServerError
    end
  end

  def fetchSummonerMasteries(sumId)
    url = "https://#{@region}.api.pvp.net/api/lol/#{@region}/v1.4/summoner/#{sumId}/masteries"
    response = HTTP.get(url, :params => { :api_key => API_KEY })

    if response.code == 200
      jsonData = response.parse.values[0]

      return {
        :summonerId => jsonData['summonerId'],
        :pages => jsonData['pages'],
        :region => @region,
      }

    elsif response.code == 404
      raise EntityNotFoundError
    elsif response.code == 429
      raise RiotLimitReached
    else
      raise RiotServerError
    end
  end

  def fetchSummonerChampionsMastery(sumId)
    url = "https://#{@region}.api.pvp.net/championmastery/location/#{regionToPlatform(@region)}/player/#{sumId}/topchampions"
    response = HTTP.get(url, :params => { :api_key => API_KEY })

    if response.code == 200
      return {
        :summonerId => sumId,
        :region => @region,
        :masteries => response.parse,
      }

    elsif response.code == 404
      return {
        :summonerId => sumId,
        :region => @region,
        :masteries => [],
      }
    elsif response.code == 429
      raise RiotLimitReached
    else
      raise RiotServerError
    end
  end

  def fetchSummonerStatsSummary(sumId, season = 'SEASON2017')
    url = "https://#{@region}.api.pvp.net/api/lol/#{@region}/v1.3/stats/by-summoner/#{sumId}/summary"
    response = HTTP.get(url, :params => { :api_key => API_KEY, :season => season })

    if response.code == 200
      return {
        :summonerId => sumId,
        :region => @region,
        :season => season,
        :playerStatSummaries => response.parse['playerStatSummaries'],
      }

    elsif response.code == 404
      return {
        :summonerId => sumId,
        :region => @region,
        :season => season,
        :playerStatSummaries => [],
      }
    elsif response.code == 429
      raise RiotLimitReached
    else
      raise RiotServerError
    end
  end
end

class RiotCache
  def initialize(region)
    @region = region
  end

  def isOutDated(updatedAt, cacheMinutes)
    diffMin = (Time.zone.now - updatedAt) / 60

    if diffMin > cacheMinutes
      return true
    end

    return false
  end

  def findSummonerByName(sumName, cacheMinutes = 5)
    summoner = Summoner.find_by(:name => sumName, :region => @region)

    if summoner and self.isOutDated(summoner.updated_at, cacheMinutes)
      summoner = false
    end

    return summoner
  end

  def saveSummonerByName(sumData)
    sumFound = Summoner.find_by(:name => sumData[:name], :region => @region)

    if sumFound
      updateData = sumData.slice(:name, :summonerLevel, :profileIconId)
      sumFound.update(updateData)
    else
      Summoner.create(sumData)
    end
  end

  def findSummonerById(sumId, cacheMinutes = 5)
    summoner = Summoner.find_by(:summonerId => sumId, :region => @region)

    if summoner and self.isOutDated(summoner.updated_at, cacheMinutes)
      summoner = false
    end

    return summoner
  end

  def saveSummonerById(sumData)
    sumFound = Summoner.find_by(:summonerId => sumData[:summonerId], :region => @region)

    if sumFound
      updateData = sumData.slice(:name, :summonerLevel, :profileIconId)
      sumFound.update(updateData)
    else
      Summoner.create(sumData)
    end
  end

  def findSummonerRunes(sumId, cacheMinutes = 5)
    runes = Rune.find_by(:summonerId => sumId, :region => @region)

    if runes and self.isOutDated(runes.updated_at, cacheMinutes)
      runes = false
    end

    return runes
  end

  def saveSummonerRunes(runesData)
    runes = Rune.find_by(:summonerId => runesData[:summonerId], :region => @region)

    if runes
      updateData = runes.slice(:pages)
      runes.update(updateData)
    else
      Rune.create(runesData)
    end
  end

  def findSummonerMasteries(sumId, cacheMinutes = 5)
    masteries = Mastery.find_by(:summonerId => sumId, :region => @region)

    if masteries and self.isOutDated(masteries.updated_at, cacheMinutes)
      masteries = false
    end

    return masteries
  end

  def saveSummonerMasteries(masteriesData)
    masteries = Mastery.find_by(:summonerId => masteriesData[:summonerId], :region => @region)

    if masteries
      updateData = masteries.slice(:pages)
      masteries.update(updateData)
    else
      Mastery.create(masteriesData)
    end
  end

  def findSummonerChampionsMastery(sumId, cacheMinutes = 5)
    masteries = ChampionsMastery.find_by(:summonerId => sumId, :region => @region)

    if masteries and self.isOutDated(masteries.updated_at, cacheMinutes)
      masteries = false
    end

    return masteries
  end

  def saveSummonerChampionsMastery(masteriesData)
    masteries = ChampionsMastery.find_by(:summonerId => masteriesData[:summonerId], :region => @region)

    if masteries
      updateData = masteries.slice(:masteries)
      masteries.update(updateData)
    else
      ChampionsMastery.create(masteriesData)
    end
  end

  def findSummonerStatsSummary(sumId, season, cacheMinutes = 5)
    stats = StatsSummary.find_by(:summonerId => sumId, :region => @region, :season => season)

    if stats and self.isOutDated(stats.updated_at, cacheMinutes)
      stats = false
    end

    return stats
  end

  def saveSummonerStatsSummary(statsData)
    stats = StatsSummary.find_by(:summonerId => statsData[:summonerId], :region => @region, :season => statsData[:season])

    if stats
      updateData = stats.slice(:playerStatSummaries)
      stats.update(updateData)
    else
      StatsSummary.create(statsData)
    end
  end
end

class RiotApi
  def initialize(region)
    @region = region
    @client = RiotClient.new(region)
    @cache = RiotCache.new(region)
  end

  def getSummonerByName(sumName)
      summoner = @cache.findSummonerByName(sumName)

      if summoner
        return summoner
      else
        summoner = @client.fetchSummonerByName(sumName)
        @cache.saveSummonerByName(summoner)
        return summoner
      end
  end

  def getSummonerById(sumId)
      summoner = @cache.findSummonerById(sumId)

      if summoner
        return summoner
      else
        summoner = @client.fetchSummonerById(sumId)
        @cache.saveSummonerById(summoner)
        return summoner
      end
  end

  def getSummonerRunes(sumId)
      runes = @cache.findSummonerRunes(sumId)

      if runes
        return runes
      else
        runes = @client.fetchSummonerRunes(sumId)
        @cache.saveSummonerRunes(runes)
        return runes
      end
  end

  def getSummonerMasteries(sumId)
      masteries = @cache.findSummonerMasteries(sumId)

      if masteries
        return masteries
      else
        masteries = @client.fetchSummonerMasteries(sumId)
        @cache.saveSummonerMasteries(masteries)
        return masteries
      end
  end

  def getSummonerChampionsMastery(sumId)
      masteries = @cache.findSummonerChampionsMastery(sumId)

      if masteries
        return masteries
      else
        masteries = @client.fetchSummonerChampionsMastery(sumId)
        @cache.saveSummonerChampionsMastery(masteries)
        return masteries
      end
  end

  def getSummonerStatsSummary(sumId, season)
      stats = @cache.findSummonerStatsSummary(sumId, season)

      if stats
        return stats
      else
        stats = @client.fetchSummonerStatsSummary(sumId, season)
        @cache.saveSummonerStatsSummary(stats)
        return stats
      end
  end
end
