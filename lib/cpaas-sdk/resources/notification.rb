require 'cpaas-sdk/util'

module Cpaas
  #
  # CPaaS notification helper methods
  #
  class Notification
    #
    # Parse inbound sms notification received in webhook. It parses the notification and returns
    # simplified version of the response.
    #
    # @param notification [Hash] JSON received in the subscription webhook.
    #
    def self.parse(notification)
      parsed_notification = convert_hash_keys(notification)
      top_level_key = parsed_notification.keys.first
      notification_obj = parsed_notification[top_level_key]

      case top_level_key
      when :outbound_sms_message_notification, :inbound_sms_message_notification
        message = notification_obj.dig(:outbound_sms_message).nil? ? notification_obj.dig(:inbound_sms_message) : notification_obj.dig(:outbound_sms_message)

        {
          notification_id: notification_obj.dig(:id),
          notification_date_time: notification_obj.dig(:date_time),
          type: types[top_level_key]
        }.merge(message)
      when :sms_subscription_cancellation_notification
        {
          subscription_id: id_from(notification_obj.dig(:link, 0, :href)),
          notification_id: notification_obj.dig(:id),
          notification_date_time: notification_obj.dig(:date_time),
          type: types[top_level_key]
        }
      when :sms_event_notification
        {
          notification_id: notification_obj.dig(:id),
          notification_date_time: notification_obj.dig(:date_time),
          message_id: id_from(notification_obj.dig(:link, 0, :href)),
          type: types[top_level_key],
          event_details: {
            description: notification_obj.dig(:event_description),
            type: notification_obj.dig(:event_type)
          }
        }
      else
        notification_obj
      end
    end

    private

    def self.types
      {
        outbound_sms_message_notification: 'outbound',
        inbound_sms_message_notification: 'inbound',
        sms_subscription_cancellation_notification: 'subscriptionCancel',
        sms_event_notification: 'event'
      }
    end
  end
end