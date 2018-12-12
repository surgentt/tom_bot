require_relative '../config/environment'

class TomBot
  attr_accessor :running, :request
  attr_reader :music_box

  def initialize
    @running = true
    @request = []
  end

  def start
    client = Slack::Web::Client.new
    p client.auth_test
  end

end