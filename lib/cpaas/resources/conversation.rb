require 'cpaas/util'

module Cpaas

  #
  # CPaaS conversation.
  #
  class Conversation
    #
    # Send a new outbound message
    #
    # @param params [Hash]
    # @option params [String] :type Type of conversation. Possible values - 'sms'. Check Conversation.types for more options
    # @option params [String] :sender_address Sender address information, basically the from address. E164 formatted DID number passed as a value, which is owned by the user. If the user wants to let CPaaS uses the default assigned DID number, this field can either has "default" value or the same value as the userId.
    # @option params [Array[string]|String] :destination_address
    # @option params [String] :message text message
    #
    def self.create_message(params)
      if params[:type] == types[:SMS]
        address = (params[:destination_address].is_a? String) ? [ params[:destination_address] ] : params[:destination_address]

        options = {
          body: {
            outboundSMSMessageRequest: {
              address: address,
              clientCorrelator: Cpaas.api.client_correlator,
              outboundSMSTextMessage: {
                message: params[:message]
              }
            }
          }
        }

        response = Cpaas.api.send_request("#{base_url}/outbound/#{params[:sender_address]}/requests", options, :post)
        process_response(response) do |res|
          outboundSMS = res.dig(:outbound_sms_message_request)

          {
            message: outboundSMS.dig(:outbound_sms_text_message, :message),
            senderAddress: outboundSMS.dig(:sender_address),
            deliveryInfo: outboundSMS.dig(:delivery_info_list, :delivery_info)
          }
        end
      end
    end

    #
    # Gets all messages.
    #
    # @param params [Hash]
    # @option params [String] :type Type of conversation. Possible values - 'sms'. Check Conversation.types for more options
    # @option params [String] :remote_address +optional+ Remote address information while retrieving the conversation history, basically the destination telephone number that user exchanged message before. E164 formatted DID number passed as a value.
    # @option params [String] :local_address +optional+ Local address information while retrieving the conversation history, basically the source telephone number that user exchanged message before.
    # @option params [String] :query[:name] +optional+ - Performs search operation on firstName and lastName fields.
    # @option params [String] :query[:first_name] +optional+ - Performs search for the first_name field of the directory items.
    # @option params [String] :query[:last_name] +optional+ - Performs search for the last_name field of the directory items.
    # @option params [String] :query[:user_name] +optional+ - Performs search for the user_name field of the directory items.
    # @option params [String] :query[:phone_number] +optional+ - Performs search for the fields containing a phone number, like businessPhoneNumber, homePhoneNumber, mobile, pager, fax.
    # @option params [String] :query[:order] +optional+ - Ordering the contact results based on the requested sortBy value, order query parameter should be accompanied by sortBy query parameter.
    # @option params [String] :query[:sort_by] +optional+ - sort_by value is used to detect sorting the contact results based on which attribute. If order is not provided with that, ascending order is used.
    # @option params [Number] :query[:max] +optional+ - Maximum number of contact results that has been requested from CPaaS for this query.
    # @option params [String] :query[:next] +optional+ - Pointer for the next chunk of contacts, should be gathered from the previous query results.
    #
    def self.get_messages(params)
      if params[:type] == types[:SMS]
        options = {
          query: params[:query]
        }

        url = "#{base_url}/remoteAddresses"
        url += "/#{params[:remote_address]}" if params[:remote_address]
        url += "/localAddresses/#{params[:local_address]}" if params[:local_address]

        response = Cpaas.api.send_request(url, options)

        process_response(response) do |res|
          if params[:local_address]
            res.dig(:sms_thread_list, :sms_thread)
              .map { |i| reject(l, :resource_url) }
          else
            message = res.dig(:sms_thread)
            reject(message, :resource_url)
          end
        end
      end
    end

    #
    # Delete conversation message
    #
    # @param params [Hash]
    # @option params [String] :type Type of conversation. Possible values - 'sms'. Check Conversation.types for more options
    # @option params [String] :remote_address Remote address information while retrieving the conversation history, basically the destination telephone number that user exchanged message before. E164 formatted DID number passed as a value.
    # @option params [String] :local_address Local address information while retrieving the conversation history, basically the source telephone number that user exchanged message before.
    # @option params [String] :message_id +optional+ Identification of the message. If messeageId is not passsed then the conversation thread is deleted with all messages.
    #
    def self.delete_message(params)
      if params[:type] == types[:SMS]
        url = "#{base_url}/remoteAddresses/#{params[:remote_address]}/localAddresses/#{params[:local_address]}"

        url += "/messages/#{params[:message_id]}" if params[:message_id]

        Cpaas.api.send_request(url, {}, :delete)
      end
    end

    #
    # Read all messages in a thread
    #
    # @param params [Hash]
    # @option params [String] :type Type of conversation. Possible values - 'sms'. Check Conversation.types for more options
    # @option params [String] :remote_address Remote address information while retrieving the conversation history, basically the destination telephone number that user exchanged message before. E164 formatted DID number passed as a value.
    # @option params [String] :local_address Local address information while retrieving the conversation history, basically the source telephone number that user exchanged message before.
    # @option params [String] :query[:next] +optional+ - Pointer for the next page to retrieve for the messages, provided by CPaaS in previous GET response.
    # @option params [String] :query[:max] +optional+ - Number of messages that is requested from CPaaS.
    # @option params [String] :query[:new] +optional+ - Filters the messages or threads having messages that are not received by the user yet.
    # @option params [String] :query[:last_Message_Time] +optional+ - Filters the messages or threads having messages that are sent/received after provided Epoch time
    #
    def self.get_messages_in_thread(params)
      if params[:type] == types[:SMS]
        options = {
          query: params[:query]
        }

        response = Cpaas.api.send_request("#{base_url}/remoteAddresses/#{params[:remote_address]}/localAddresses/#{params[:local_address]}/messages", options)

        process_response(response) do |res|
          res.dig(:sms_message_list, :sms_message)
          .map { |m| reject(m, :resource_url) }
        end
      end
    end

    #
    # Read a conversation message status
    #
    # @param params [Hash]
    # @option params [String] :type Type of conversation. Possible values - 'sms'. Check Conversation.types for more options
    # @option params [String] :remote_address Remote address information while retrieving the conversation history, basically the destination telephone number that user exchanged message before. E164 formatted DID number passed as a value.
    # @option params [String] :local_address Local address information while retrieving the conversation history, basically the source telephone number that user exchanged message before.
    # @option params [String] :message_id Identification of the message. If messeageId is not passsed then the conversation thread is deleted with all messages.
    #
    def self.get_status(params)
      if params[:type] == types[:SMS]
        Cpaas.api.send_request("#{base_url}/remoteAddresses/#{params[:remote_address]}/localAddresses/#{params[:local_address]}/messages/#{params[:message_id]}/status")
      end
    end

    #
    # Read all active subscriptions
    #
    # @option params [String] :type Type of conversation. Possible values - 'sms'. Check Conversation.types for more options
    #

    def self.get_subscriptions(params)
      if params[:type] == types[:SMS]
        response = Cpaas.api.send_request("#{base_url}/inbound/subscriptions")

        process_response(response) do |res|
          res.dig(:subscription_list, :subscription)
            .map do |subscriptions|
              {
                notify_url: subscription.dig(:callback_reference, :notify_url),
                destination_address: subscription.dig(:destination_address),
                subscription_id: id_from(subscription.dig(:resource_url))
              }
            end
        end
      end
    end

    #
    # Read active subscription
    #
    # @param params [Hash]
    # @option params [String] :type Type of conversation. Possible values - 'sms'. Check Conversation.types for more options
    # @option params [String] :subscription_id Resource ID of the subscription
    #
    def self.get_subscription(params)
      if params[:type] == types[:SMS]
        response = Cpaas.api.send_request("#{base_url}/inbound/subscriptions/#{params[:subscription_id]}")

        process_response(response) do |res|
          subscription = res.dig(:subscription)

          {
            notify_url: subscription.dig(:callback_reference, :notify_url),
            destination_address: subscription.dig(:destination_address),
            subscription_id: id_from(subscription.dig(:resource_url))
          }
        end
      end
    end

    #
    # Create a new subscription
    #
    # @param params [Hash]
    # @option params [String] :type Type of conversation. Possible values - 'sms'. Check Conversation.types for more options
    # @option params [String] :webhook_url The notification channel ID that has been acquired during /notificationchannel API subscription, either websockets, mobile push or webhooks type, which the incoming notifications supposed to be sent to.
    # @option params [String] :destination_address +optional+ The address that incoming messages are received for this subscription. If does not exist, CPaaS uses the default assigned DID number to subscribe against. It is suggested to provide the intended E164 formatted DID number within this parameter.
    #

    def self.subscribe(params)
      if params[:type] == types[:SMS]
        channel = Cpaas::NotificationChannel.create_channel(webhook_url: params[:webhook_url])

        return channel if !channel.dig(:exception_id).nil?

        options = {
          body: {
            subscription: {
              callbackReference: {
                notifyURL: channel[:channel_id]
              },
              clientCorrelator: Cpaas.api.client_correlator,
              destinationAddress: params[:destination_address]
            }
          }
        }

        response = Cpaas.api.send_request("#{base_url}/inbound/subscriptions", options, :post)

        process_response(response) do |res|
          {
            webhook_url: params[:webhook_url],
            destination_address: response.dig(:subscription, :destination_address),
            subscription_id: id_from(response.dig(:subscription, :resource_url))
          }
        end
      end
    end

    #
    # Unsubscription from conversation notification
    #
    # @param params [Hash]
    # @option params [String] :subscription_id Resource ID of the subscription.
    #

    def self.unsubscribe(params = {})
      if params[:type] == types[:SMS]
        response = Cpaas.api.send_request("#{base_url}/inbound/subscriptions/#{params[:subscription_id]}", {}, :delete)

        process_response(response) do |res|
          {
            subscription_id: params[:subscription_id],
            success: true,
            message: "Unsubscribed from #{params[:type]} conversation notification"
          }
        end
      end
    end

    # @private
    def self.types
      {
        SMS: 'sms'
      }
    end

    private

    def self.base_url
      "/cpaas/smsmessaging/v1/#{Cpaas.api.user_id}"
    end
  end
end
