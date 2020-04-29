require 'httparty'
require 'jwt'

require 'cpaas-sdk/util'

module Cpaas
  # @private
  class Api
    include HTTParty
    format :json

    attr_accessor :user_id, :client_correlator

    def initialize(config)
      @config = config
      @id_token_parsed = nil
      @access_token = nil
      @user_id = nil
      @client_correlator = "#{config.client_id}-ruby"

      self.class.base_uri config.base_url

      auth_token
    end

    def send_request(url, options = {}, verb = :get, with_token = true)
      body = recursive_compact(options[:body]) if options[:body]
      options[:headers] = headers(options[:headers] || {}, with_token)
      options[:body] = body.to_json if options[:headers]['Content-Type'] == 'application/json'
      options[:query] = options[:query] if options.has_key? :query

      case verb
      when :get
        response = self.class.get(url, options)
      when :post
        response = self.class.post(url, options)
      when :put
        response = self.class.put(url, options)
      when :delete
        response = self.class.delete(url, options)
      else
        raise 'Invalid Verb'
      end

      handle_response(response)
    end

    def handle_response(response)
      @parsed_response = begin
        res = convert_hash_keys(response.parsed_response)

        if response.code >= 400 && !res.nil?
          compose_error_from(res)
        else
          res || { status_code: response.code, response: response }
        end
      rescue JSON::ParserError => e
        response.success? ? { message: response.body } : { error: response.body }
      end
    end

    def headers(request_headers = {}, with_token = false)
      base_headers = {
        'X-Cpaas-Agent' => "ruby-sdk/#{Cpaas::VERSION}",
        'Content-Type' => 'application/json',
        'Accept' => '*/*',
      }.merge(request_headers)

      return base_headers.merge(auth_headers) if with_token

      base_headers
    end

    def auth_headers
      {
        'Authorization' => "Bearer #{auth_token}"
      }
    end

    def auth_token
      set_tokens(get_auth_token) if token_expired

      @access_token
    end

    def get_auth_token
      options = {
        body: {
          client_id: @config.client_id,
          scope: 'openid'
        },
        headers: {
          'Content-Type' => 'application/x-www-form-urlencoded'
        }
      }

      if !@config.client_secret.nil?
        credentials = {
          grant_type: 'client_credentials',
          client_secret: @config.client_secret
        }
      else
        credentials = {
          grant_type: 'password',
          username: @config.email,
          password: @config.password
        }
      end

      options[:body].merge!(credentials)

      response = send_request('/cpaas/auth/v1/token', options, :post , false)

      process_response(response, false)
    end

    def token_expired
      return true if @access_token.nil?

      min_buffer = (@token_parsed['exp'] - @token_parsed['iat']) / 2
      expires_in = @token_parsed['exp'] - Time.now.to_i - min_buffer

      expires_in < 0
    end

    def set_tokens(tokens)
      if tokens[:access_token].nil?
        @access_token = nil
        @id_token = nil
        @id_token_parsed = nil
        @user_id = nil
      else
        @access_token = tokens[:access_token]
        @id_token = tokens[:id_token]
        @id_token_parsed = JWT.decode(tokens[:id_token], nil, false).first
        @token_parsed = JWT.decode(tokens[:access_token], nil, false).first
        @user_id = @id_token_parsed['preferred_username']
      end
    end

    def recursive_compact(hash_or_array)
      p = proc do |*args|
        v = args.last
        v.delete_if(&p) if v.respond_to? :delete_if
        v.nil? || v.respond_to?(:"empty?") && v.empty?
      end

      hash_or_array.delete_if(&p)
    end
  end
end
