require 'spec_helper'

RSpec.describe Cpaas::Notification do
  describe '.parse' do
    it 'parses inbound SMS notification' do
      notification = {
        "inboundSMSMessageNotification": {
          "inboundSMSMessage": {
            "dateTime": 1525895987,
            "destinationAddress": "+16137001234",
            "message": "hi",
            "messageId": "O957s10JReNV",
            "senderAddress": "+16139998877"
          },
          "dateTime": 1525895987,
          "id": "441fc36e-aab7-45dd-905c-4aaec7a7464d"
        }
      }

      expected_parsed_response = {
        notification_date_time: 1525895987,
        date_time: 1525895987,
        destination_address: '+16137001234',
        message: 'hi',
        message_id: 'O957s10JReNV',
        sender_address: '+16139998877',
        type: 'inbound',
        notification_id: '441fc36e-aab7-45dd-905c-4aaec7a7464d'
      }

      parsed_response = Cpaas::Notification.parse(notification)

      expect(parsed_response).to eq(expected_parsed_response)
    end

    it 'parses outbound SMS notification' do
      notification = {
        "outboundSMSMessageNotification": {
          "outboundSMSMessage": {
            "dateTime": 1525895987,
            "destinationAddress": "+16139998877",
            "message": "hi",
            "messageId": "olr3j20Cdx87",
            "senderAddress": "+16137001234"
          },
          "dateTime": 1525895987,
          "id": "441fc36e-aab7-45dd-905c-4aaec7a7464d"
        }
      }

      expected_parsed_response = {
        notification_date_time: 1525895987,
        date_time: 1525895987,
        destination_address: '+16139998877',
        message: 'hi',
        message_id: 'olr3j20Cdx87',
        sender_address: '+16137001234',
        type: 'outbound',
        notification_id: '441fc36e-aab7-45dd-905c-4aaec7a7464d'
      }

      parsed_response = Cpaas::Notification.parse(notification)

      expect(parsed_response).to eq(expected_parsed_response)
    end

    it 'parses sms subscription cancellation notification' do
      notification = {
        "smsSubscriptionCancellationNotification": {
          "link": [
            {
              "href": "/cpaas/smsmessaging/v1/e33c51d7-6585-4aee-88ae-005dfae1fd3b/inbound/subscriptions/f179f10b-e846-4370-af20-db5f7dc0f985",
              "rel": "Subscription"
            }
          ],
          "dateTime": 1525895987,
          "id": "441fc36e-aab7-45dd-905c-4aaec7a7464d"
        }
      }

      expected_parsed_response = {
        subscription_id: 'f179f10b-e846-4370-af20-db5f7dc0f985',
        notification_id: '441fc36e-aab7-45dd-905c-4aaec7a7464d',
        notification_date_time: 1525895987,
        type: 'subscriptionCancel'
      }

      parsed_response = Cpaas::Notification.parse(notification)

      expect(parsed_response).to eq(expected_parsed_response)
    end

    it 'parses sms event notification' do
      notification = {
        "smsEventNotification": {
          "eventDescription": "A message has been deleted.",
          "eventType": "MessageDeleted",
          "link": [
            {
              "href": "/cpaas/smsmessaging/v1/92ef716d-42c7-4706-a123-b36cac9a2f97/remoteAddresses/+12013000113/localAddresses/+12282202950/messages/SM5C24C4AB0001020821100077367A8A",
              "rel": "smsMessage"
            }
          ],
          "id": "8c30d6c7-d15e-41a0-800b-e7dc401403fb",
          "dateTime": 1545995973646
        }
      }

      expected_parsed_response = {
        notification_id: '8c30d6c7-d15e-41a0-800b-e7dc401403fb',
        notification_date_time: 1545995973646,
        message_id: 'SM5C24C4AB0001020821100077367A8A',
        type: 'event',
        event_details: {
          description: 'A message has been deleted.',
          type: 'MessageDeleted'
        }
      }

      parsed_response = Cpaas::Notification.parse(notification)

      expect(parsed_response).to eq(expected_parsed_response)
    end
  end
end