Dir[File.join(File.dirname(__FILE__), '../app', '*.rb')].each {|f| require f}

Slack.configure do |config|
  config.token = ENV['SLACK_API_TOKEN']
end