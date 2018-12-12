require_relative '../config/environment'

class TomBot
  attr_reader :realtime_client, :web_client, :channel

  def initialize
    @running = true
    @realtime_client = Slack::RealTime::Client.new
    @channel = 'GEQ1ZN24W'
  end

  def listen
    self.realtime_client.on :hello do
      puts "Successfully connected, welcome '#{realtime_client.self.name}' to the '#{realtime_client.team.name}' team at https://#{realtime_client.team.domain}.slack.com."
    end
    self.realtime_client.on :message do |data|
      if data.message
        case data.message.text
        when '<@UEPM3KUTH> hi bot' then
          slack_message(data.channel, "Hi <@#{data.message.user}>!")
        when '<@UEPM3KUTH> Weather now' then 
          slack_message(data.channel, current_weather_msg)
        when '<@UEPM3KUTH> Weather tomorrow' then 
          slack_message(data.channel, weather_tomorrow_msg)
        when '<@UEPM3KUTH> Forecast' then 
          slack_message(data.channel, multi_day_forecast)
        when '<@UEPM3KUTH> Weather difference' then 
          large_weather_change(data.channel)
        else
          slack_message(data.channel, "Sorry <@#{data.user}>, what?")
        end
      else
        puts data
      end
    end
    realtime_client.start!
  end

  def large_weather_change(channel=self.channel)
    current_forecast   = ForecastIO.forecast(40.7128, -74.0060)['currently']
    yesterday_forecast = ForecastIO.forecast(40.7128, -74.0060,  time: (Time.now-1.day).to_i)['currently']
    temp_change = (current_forecast['temperature'] - yesterday_forecast['temperature']).abs
    if temp_change > 8
      slack_message(channel, "Temperature Change from Yesterday of #{temp_change.to_s}")
    else
      slack_message(channel, "No Major Temperature Change")
    end
  end

  private

    def current_weather_msg
      forecast = ForecastIO.forecast(40.7128, -74.0060)['currently']
      text_response = "Weather Now\n"
      text_response += forecast_text(forecast)
      text_response
    end

    def weather_tomorrow_msg
      forecast = ForecastIO.forecast(40.7128, -74.0060, time: (Time.now+1.day).to_i)['currently']
      text_response = "Weather in 24 Hours\n"
      text_response += forecast_text(forecast)
      text_response
    end

    def multi_day_forecast
      text_response = "Multi Day Forecast \n"
      6.times do |i|
        i == 0 ? text_response += "Today's Weather \n" : text_response += "Weather in #{i} day\n"
        forecast = ForecastIO.forecast(40.7128, -74.0060, time: (Time.now+i.day).to_i)['currently']
        text_response += forecast_text(forecast)
      end
      text_response
    end

    def forecast_text(forecast)
      text_response = ''
      text_response += ('Summary: '     + forecast['summary'] + "\n")
      text_response += ('Temperature: ' + forecast['temperature'].to_s + "\n")
      text_response += ('Wind Speed: '  + forecast['windSpeed'].to_s  + "\n")
      text_response += ('Precipitation Propbability: ' + forecast['precipProbability'].to_s  + "\n")
      text_response
    end

    def slack_message(channel, message)
      web_client = Slack::Web::Client.new
      web_client.auth_test
      web_client.chat_postMessage(channel: channel, text: message, as_user: false)
    end

end