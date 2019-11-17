require 'cpaas-sdk/util'

module Cpaas
  # @private

  class NotificationChannel
    def self.create_channel(params)
      options = {
        body: {
          notificationChannel: {
            channelData: {
              'x-webhookURL': params[:webhook_url]
            },
            channelType: 'webhooks',
            clientCorrelator: Cpaas.api.client_correlator
          }
        }
      }

      response = Cpaas.api.send_request("#{base_url}/channels", options, :post)

      process_response(response) do |res|
        channel = res.dig(:notification_channel)

        {
          channel_id: channel[:callback_url],
          webhook_url: channel[:channel_data][:x_webhook_url],
          channel_type: channel[:channel_type]
        }
      end
    end

    private

    def self.base_url
      "/cpaas/notificationchannel/v1/#{Cpaas.api.user_id}"
    end
  end
end