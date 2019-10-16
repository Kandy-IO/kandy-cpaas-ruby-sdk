require 'cpaas/util'

module Cpaas
  ##
  # CPaaS provides Authentication API where a two-factor authentication (2FA) flow can be implemented by using that.
  # Sections below describe two sample use cases, two-factor authentication via SMS and two-factor authentication via e-mail
  #

  class Twofactor
    #
    # Create a new authentication code.
    #
    # @param params [Hash]
    # @option params [String|Array[string]] :destination_address Destination address of the authentication code being sent. For sms type authentication codes, it should contain a E164 phone number. For e-mail type authentication codes, it should contain a valid e-mail address.
    # @option params [String] :message Message text sent to the destination, containing the placeholder for the code within the text. CPaaS requires to have *{code}* string within the text in order to generate a code and inject into the text. For email type code, one usage is to have the *{code}* string located within the link in order to get a unique link.
    # @option params [String] :method ('sms') +optional+ Type of the authentication code delivery method, sms and email are supported types. Possible values: sms, email
    # @option params [Number] :expiry (120) +optional+ Lifetime duration of the code sent in seconds. This can contain values between 30 and 3600 seconds.
    # @option params [Number] :length (6) +optional+ Length of the authentication code tha CPaaS should generate for this request. It can contain values between 4 and 10.
    # @option params [String] :type ('numeric') +optional+ Type of the code that is generated. If not provided, default value is numeric. Possible values: numeric, alphanumeric, alphabetic
    #
    def self.send_code(params = {})
      address = (params[:destination_address].is_a? String) ? [ params[:destination_address] ] : params[:destination_address]

      options = {
        body: {
          code: {
            address: address,
            method: params[:method] || 'sms',
            format: {
              length: params[:length] || 6,
              type: params[:type] || 'numeric'
            },
            expiry: params[:expiry] || 120,
            message: params[:message]
          }
        }
      }

      response = Cpaas.api.send_request("#{base_url}/codes", options, :post)

      process_response(response) do |res|
        {
          code_id: id_from(res.dig(:code, :resource_url))
        }
      end
    end

    #
    # Verifying authentication code
    #
    # @param params [Hash]
    # @option params [String] :code_id ID of the authentication code.
    # @option params [String] :verification_code Code that is being verified
    #
    def self.verify_code(params = {})
      options = {
        body: {
          code: {
            verify: params[:verification_code]
          }
        }
      }

      response = Cpaas.api.send_request("#{base_url}/codes/#{params[:code_id]}/verify", options, :put)

      process_response(response) do |res|
        if res[:status_code] == 204
          {
            verified: true,
            message: 'Success'
          }
        else
          {
            verified: false,
            message: 'Code invalid or expired'
          }
        end
      end
    end

    ##
    # Resending the authentication code via same code resource, invalidating the previously sent code.
    #
    # @param params [Hash]
    # @option params [String|Array[string]] :destination_address Destination address of the authentication code being sent. For sms type authentication codes, it should contain a E164 phone number. For e-mail type authentication codes, it should contain a valid e-mail address.
    # @option params [String] :message Message text sent to the destination, containing the placeholder for the code within the text. CPaaS requires to have *{code}* string within the text in order to generate a code and inject into the text. For email type code, one usage is to have the *{code}* string located within the link in order to get a unique link.
    # @option params [String] :code_id ID of the authentication code.
    # @option params [String] :method ('sms') +optional+ Type of the authentication code delivery method, sms and email are supported types. Possible values: sms, email
    # @option params [Number] :expiry (120) +optional+ Lifetime duration of the code sent in seconds. This can contain values between 30 and 3600 seconds.
    # @option params [Number] :length (6) +optional+ Length of the authentication code tha CPaaS should generate for this request. It can contain values between 4 and 10.
    # @option params [String] :type ('numeric') +optional+ Type of the code that is generated. If not provided, default value is numeric. Possible values: numeric, alphanumeric, alphabetic
    #
    def self.resend_code(params = {})
      address = (params[:destination_address].is_a? String) ? [ params[:destination_address] ] : params[:destination_address]

      options = {
        body: {
          code: {
            address: address,
            method: params[:method] || 'sms',
            format: {
              length: params[:length] || 6,
              type: params[:type] || 'numeric'
            },
            expiry: params[:expiry] || 120,
            message: params[:message]
          }
        }
      }

      response = Cpaas.api.send_request("#{base_url}/codes/#{params[:code_id]}", options, :put)

      process_response(response) do |res|
        {
          code_id: id_from(res.dig(:code, :resource_url))
        }
      end
    end

    #
    # Delete authentication code resource.
    #
    # @param [Hash] params
    # @option params [String] :code_id ID of the authentication code.
    #
    def self.delete_code(params = {})
      Cpaas.api.send_request("#{base_url}/codes/#{params[:code_id]}", {}, :delete)
    end

    private

    def self.base_url
      "/cpaas/auth/v1/#{Cpaas.api.user_id}"
    end
  end
end
