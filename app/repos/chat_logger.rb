require 'slack-notifier'

module Repos
  # Responsible for log errors on Work Chat Ex: Slack
  class ChatLogger
    def self.notify_on_client_channel(message)
      notifier = Slack::Notifier.new ENV['SLACK_WEBHOOK_URL'] do
        defaults channel: "##{ENV['SLACK_CLIENT_CHANNEL']}",
                 username: "notifier"
      end

      notifier.ping(message)
    end
  end
end