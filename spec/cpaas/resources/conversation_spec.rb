require 'spec_helper'

RSpec.describe Cpaas::Conversation do
  before do
    stub_token

    Cpaas.configure do |config|
      config.client_id = 'client-id'
      config.client_secret = 'client-secret'
      config.base_url = 'https://oauth-cpaas.att.com'
    end

    @base_url = "/cpaas/smsmessaging/v1/#{Cpaas.api.user_id}"
  end

  describe '.create_message' do
    context 'when given valid params' do
      it 'generates valid url and body' do
        sender_address = '123'
        params = {
          type: Cpaas::Conversation.types[:SMS],
          sender_address: sender_address,
          destination_address: ['123', '234', '345'],
          message: 'test message'
        }

        expected_body = {
          outboundSMSMessageRequest: {
            address: ['123', '234', '345'],
            clientCorrelator: Cpaas.api.client_correlator,
            outboundSMSTextMessage: {
              message: 'test message'
            }
          }
        }.to_json

        url = "#{@base_url}/outbound/#{sender_address}/requests"

        stub(url, :post)

        response = Cpaas::Conversation.create_message(params)

        expect(response[:__for_test__][:body]).to eq(expected_body)
        expect(response[:__for_test__][:url]).to eq(url)
      end
    end
  end

  describe '.get_messages' do
    context 'when given no params' do
      it 'generates valid url' do
        url = "#{@base_url}/remoteAddresses"
        params = {
          type: Cpaas::Conversation.types[:SMS]
        }

        stub(url, :get)

        response = Cpaas::Conversation.get_messages(params)

        expect(response[:__for_test__][:url]).to eq(url)
      end
    end

    context 'when given remote_address as param' do
      it 'generates valid url' do
        remote_address = 'test-remote-address'
        url = "#{@base_url}/remoteAddresses/#{remote_address}"
        params = {
          type: Cpaas::Conversation.types[:SMS],
          remote_address: remote_address
        }

        stub(url, :get)

        response = Cpaas::Conversation.get_messages(params)

        expect(response[:__for_test__][:url]).to eq(url)
      end
    end

    context 'when given remote_address and local_address as param' do
      it 'generates valid url' do
        remote_address = 'test-remote-address'
        local_address = 'test-local-address'
        url = "#{@base_url}/remoteAddresses/#{remote_address}/localAddresses/#{local_address}"
        params = {
          type: Cpaas::Conversation.types[:SMS],
          remote_address: remote_address,
          local_address: local_address
        }

        stub(url, :get)

        response = Cpaas::Conversation.get_messages(params)

        expect(response[:__for_test__][:url]).to eq(url)
      end
    end
  end

  describe '.delete_message' do
    context 'when given required params' do
      it 'generates valid url' do
        remote_address = 'test-remote-address'
        local_address = 'test-local-address'
        url = "#{@base_url}/remoteAddresses/#{remote_address}/localAddresses/#{local_address}"
        params = {
          type: Cpaas::Conversation.types[:SMS],
          remote_address: remote_address,
          local_address: local_address
        }

        stub(url, :delete)

        response = Cpaas::Conversation.delete_message(params)

        expect(response[:__for_test__][:url]).to eq(url)
      end
    end

    context 'when given all params' do
      it 'generates valid url' do
        remote_address = 'test-remote-address'
        local_address = 'test-local-address'
        message_id = 'test-message-id'
        url = "#{@base_url}/remoteAddresses/#{remote_address}/localAddresses/#{local_address}/messages/#{message_id}"
        params = {
          type: Cpaas::Conversation.types[:SMS],
          remote_address: remote_address,
          local_address: local_address,
          message_id: message_id
        }

        stub(url, :delete)

        response = Cpaas::Conversation.delete_message(params)

        expect(response[:__for_test__][:url]).to eq(url)
      end
    end
  end

  describe '.get_messages_in_thread' do
    context 'when given valid params' do
      it 'generates valid url' do
        remote_address = 'test-remote-address'
        local_address = 'test-local-address'

        url = "#{@base_url}/remoteAddresses/#{remote_address}/localAddresses/#{local_address}/messages"

        params = {
          type: Cpaas::Conversation.types[:SMS],
          remote_address: remote_address,
          local_address: local_address
        }

        stub(url, :get)

        response = Cpaas::Conversation.get_messages_in_thread(params)

        expect(response[:__for_test__][:url]).to eq(url)
      end
    end
  end

  describe '.get_status' do
    context 'when given valid params' do
      it 'generates valid url' do
        remote_address = 'test-remote-address'
        local_address = 'test-local-address'
        message_id = 'test-message-id'

        url = "#{@base_url}/remoteAddresses/#{remote_address}/localAddresses/#{local_address}/messages/#{message_id}/status"

        params = {
          type: Cpaas::Conversation.types[:SMS],
          remote_address: remote_address,
          local_address: local_address,
          message_id: message_id
        }

        stub(url, :get)

        response = Cpaas::Conversation.get_status(params)

        expect(response[:__for_test__][:url]).to eq(url)
      end
    end
  end

  describe '.get_subscriptions' do
    context 'when called' do
      it 'generates valid url' do
        url = "#{@base_url}/inbound/subscriptions"
        params = {
          type: Cpaas::Conversation.types[:SMS]
        }

        stub(url, :get)

        response = Cpaas::Conversation.get_subscriptions(params)

        expect(response[:__for_test__][:url]).to eq(url)
      end
    end
  end

  describe '.get_subscription' do
    context 'when given valid params' do
      it 'generates valid url' do
        subscription_id = 'test-subscription-id'
        url = "#{@base_url}/inbound/subscriptions/#{subscription_id}"
        params = {
          type: Cpaas::Conversation.types[:SMS],
          subscription_id: subscription_id
        }

        stub(url, :get)

        response = Cpaas::Conversation.get_subscription(params)

        expect(response[:__for_test__][:url]).to eq(url)
      end
    end
  end

  describe '.subscribe' do
    before do
      @callback_url = 'wh-72b43d88-4cc1-466e-a453-ecbea3733a2e'
      @url = "#{@base_url}/inbound/subscriptions"
      channel_url = "/cpaas/notificationchannel/v1/#{Cpaas.api.user_id}/channels"

      stub(@url, :post)
      stub(channel_url, :post, {
        notificationChannel: {
          callbackURL: @callback_url,
          channelData: {
            'x-webhookURL': 'https://myapp.com/abc123',
            'x-authorization': 'Bearer someAccessToken'
          },
          channelType: 'Webhooks',
          clientCorrelator: 'someClientCorrelator',
          resourceURL: '/cpaas/notificationchannel/v1/e33c51d7-6585-4aee-88ae-005dfae1fd3b/channels/wh-72b43d88-4cc1-466e-a453-ecbea3733a2e'
        }
      })
    end

    context 'when given required params' do
      it 'generates valid url and body' do
        params = {
          type: Cpaas::Conversation.types[:SMS],
          webhook_url: 'test-notify-url'
        }

        expected_body = {
          subscription: {
            callbackReference: {
              notifyURL: @callback_url
            },
            clientCorrelator: Cpaas.api.client_correlator
          }
        }.to_json

        response = Cpaas::Conversation.subscribe(params)

        expect(response[:__for_test__][:url]).to eq(@url)
        expect(response[:__for_test__][:body]).to eq(expected_body)
      end
    end

    context 'when given all params' do
      it 'generates valid url and body' do
        params = {
          type: Cpaas::Conversation.types[:SMS],
          notify_url: 'test-notify-url',
          destination_address: 'test-destination-address'
        }

        expected_body = {
          subscription: {
            callbackReference: {
              notifyURL: @callback_url
            },
            clientCorrelator: Cpaas.api.client_correlator,
            destinationAddress: 'test-destination-address'
          }
        }.to_json

        response = Cpaas::Conversation.subscribe(params)

        expect(response[:__for_test__][:url]).to eq(@url)
        expect(response[:__for_test__][:body]).to eq(expected_body)
      end
    end
  end

  describe '.unsubscribe' do
    context 'when given valid params' do
      it 'generates valid url' do
        subscription_id = 'test-subscription-id'
        url = "#{@base_url}/inbound/subscriptions/#{subscription_id}"
        params = {
          type: Cpaas::Conversation.types[:SMS],
          subscription_id: subscription_id
        }

        stub(url, :delete)

        response = Cpaas::Conversation.unsubscribe(params)

        expect(response[:__for_test__][:url]).to eq(url)
      end
    end
  end
end