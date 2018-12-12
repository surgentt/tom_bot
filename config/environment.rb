require 'yaml'
require 'slack-ruby-client'
require 'pry'

secrets_location = File.join(File.dirname(__FILE__), './secrets.yml')
ENV_CONFIG = YAML.load_file(secrets_location)

Dir[File.join(File.dirname(__FILE__), '../app', '*.rb')].each {|f| require f}

Slack.configure do |config|
  config.token = ENV_CONFIG['TOM_BOT']
end