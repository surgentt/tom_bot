require_relative '../config/environment'

class TomBot
  attr_reader :client

  def initialize
    @running = true
    @client = Slack::RealTime::Client.new
    listen
  end

  def listen
    client.on :hello do
      puts "Successfully connected, welcome '#{client.self.name}' to the '#{client.team.name}' team at https://#{client.team.domain}.slack.com."
    end

    client.on :message do |data|
      case data.message.text
      when '<@UEPM3KUTH> hi bot' then
        slack_message(data.channel, "Hi <@#{data.message.user}>!")
      when '<@UEPM3KUTH> Weather now' then 
        slack_message(data.channel, current_weather_msg)
      when '<@UEPM3KUTH> Weather tomorrow' then 
        slack_message(data.channel, weather_tomorrow_msg)
      when /^bot/ then
        slack_message(data.channel, "Sorry <@#{data.user}>, what?")
      end
    end

    client.start!
  end

  private

    def current_weather_msg
      current_forecast = ForecastIO.forecast(40.7128, -74.0060)['currently']
      text_response = "Weather Now\n"
      text_response += ('Summary: '     + current_forecast['summary'] + "\n")
      text_response += ('Temperature: ' + current_forecast['temperature'].to_s + "\n")
      text_response += ('Wind Speed: '  + current_forecast['windSpeed'].to_s  + "\n")
      text_response += ('Precipitation Propbability: ' + current_forecast['precipProbability'].to_s  + "\n")
      text_response
    end

    def weather_tomorrow_msg
      tmrw_forecast = ForecastIO.forecast(40.7128, -74.0060,  time: (Time.now+1.day).to_i)['currently']
      text_response = "Weather in 24 Hours\n"
      text_response += ('Summary: '     + tmrw_forecast['summary'] + "\n")
      text_response += ('Temperature: ' + tmrw_forecast['temperature'].to_s + "\n")
      text_response += ('Wind Speed: '  + tmrw_forecast['windSpeed'].to_s  + "\n")
      text_response += ('Precipitation Propbability: ' + tmrw_forecast['precipProbability'].to_s  + "\n")
      text_response
    end

    def slack_message(channel, message)
      client.message(channel: channel, text: message)
    end

end