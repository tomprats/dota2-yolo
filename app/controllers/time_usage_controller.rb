class TimeUsageController < ApplicationController
  require 'open-uri'
  require 'json'

  def show
    @id = params[:steam][:id]
    get_matches
    get_time
  end

  private
  def get_matches
    begin
      json = get25_matches
      if @matches
        @matches += JSON.parse(json)["result"]["matches"]
      else
        @matches = JSON.parse(json)["result"]["matches"]
      end
      puts @matches.length
    end while json.present? && JSON.parse(json)["result"]["matches"].length != 0
  end

  def get25_matches
    account = "account_id=#{@id}"
    key = "key=9172F935E5A34482E0D0F0118D26A4C9"
    url = "https://api.steampowered.com/IDOTA2Match_570/GetMatchHistory/V001/?"
    full_url = url + "#{account}&#{key}"
    if @matches
      first_match_id = @matches.last["match_id"] - 1
      full_url += "&start_at_match_id=#{first_match_id}"
      date_max = @matches.last["start_time"] - 1
      full_url += "&date_max=#{date_max}"
    end
    json = open(full_url).read
  end

  def get_time
    @matches.each_with_index do |match, index|
      details = JSON.parse(get_match_details(match))
      if @time
        @time += details["result"]["duration"]
      else
        @time = details["result"]["duration"]
      end
      puts "Time: #{@time} Index: #{index} of #{@matches.count}"
    end
  end

  def get_match_details(match)
    key = "key=9172F935E5A34482E0D0F0118D26A4C9"
    match_param = "match_id=#{match["match_id"]}"
    url = "https://api.steampowered.com/IDOTA2Match_570/GetMatchDetails/V001/?"
    full_url = url + "#{match_param}&#{key}"
    json = open(full_url).read
  end
end
