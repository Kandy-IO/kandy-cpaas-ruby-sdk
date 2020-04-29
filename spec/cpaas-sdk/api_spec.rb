require 'spec_helper'

RSpec.describe Cpaas::Api do
  before do
    stub_token
  end

  describe '#initialize' do
    context 'when given a valid params' do
      it 'sets user_id' do

        config = Cpaas::Config.new
        config.client_id = 'test-client-id'
        config.client_secret = 'test-client-secret'
        config.base_url = 'https://oauth-cpaas.att.com'

        api = Cpaas::Api.new(config)

        expect(api.user_id).not_to be_nil
      end
    end
  end

  describe '#send_request' do
    before do
      stub('/test', :post)

      config = Cpaas::Config.new
      config.client_id = 'test-client-id'
      config.client_secret = 'test-client-secret'
      config.base_url = 'https://oauth-cpaas.att.com'

      @api = Cpaas::Api.new(config)
    end

    context 'when given valid param' do
      before do
        options = {
          body: {
            param1: 'test-param1',
            param2: 'test-param2'
          },
          headers: {
            header1: 'test-header'
          }
        }

        @response = @api.send_request('/test', options, :post)
      end

      it 'sends valid json body' do
        expected_body = {
          param1: 'test-param1',
          param2: 'test-param2'
        }.to_json

        expect(@response[:__for_test__][:body]).to eq(expected_body)
      end

      it 'generates valid headers with token' do
        headers = JSON.parse(@response[:__for_test__][:headers])

        expect(headers['Content-Type']).to eq('application/json')
        expect(headers['Accept']).to eq('*/*')
        expect(headers['Authorization']).to_not be_nil
        expect(headers['Authorization']).to start_with('Bearer')
        expect(headers['Authorization'].length).to be > 50
      end
    end

    context 'when given param with_token false' do
      it 'does not set auth token in header' do
        options = {
          body: {
            param1: 'test-param1'
          }
        }

        response = @api.send_request('/test', options, :post, false)

        headers = JSON.parse(response[:__for_test__][:headers])
        expect(headers['Content-Type']).to eq('application/json')
        expect(headers['Accept']).to eq('*/*')
        expect(headers['Authorization']).to be_nil
      end
    end

  end
  describe '#headers' do
    before do
      config = Cpaas::Config.new
      config.client_id = 'test-client-id'
      config.client_secret = 'test-client-secret'
      config.base_url = 'https://oauth-cpaas.att.com'

      @api = Cpaas::Api.new(config)
    end

    context 'no params' do
      it 'returns base headers' do
        base_headers = {
          'X-Cpaas-Agent' => "ruby-sdk/#{Cpaas::VERSION}",
          'Content-Type' => 'application/json',
          'Accept' => '*/*',
        }

        headers = @api.headers

        expect(headers).not_to be_nil
        expect(headers).to eq(base_headers)
      end
    end

    context 'with request params' do
      it 'returns base headers and request headers' do
        request_headers = {
          'test-header' => 'value-header'
        }

        expected_headers = {
          'X-Cpaas-Agent' => "ruby-sdk/#{Cpaas::VERSION}",
          'Content-Type' => 'application/json',
          'Accept' => '*/*',
          'test-header' => 'value-header'
        }


        headers = @api.headers(request_headers)

        expect(headers).not_to be_nil
        expect(headers).to eq(expected_headers)
      end
    end

    context 'with request params and with_token flag as true' do
      it 'returns base headers, request headers and auth token header' do
        base_headers = {
          'Content-Type' => 'application/json',
          'Accept' => '*/*'
        }

        request_headers = {
          'test-header' => 'header-value'
        }


        headers = @api.headers(request_headers, true)

        expect(headers).not_to be_nil
        expect(headers['Content-Type']).to eq('application/json')
        expect(headers['Accept']).to eq('*/*')
        expect(headers['test-header']).to eq('header-value')
        expect(headers['Authorization']).to_not be_nil
        expect(headers['Authorization']).to start_with('Bearer')
        expect(headers['Authorization'].length).to be > 50
      end
    end
  end

  describe '#auth_header' do
    context 'when called' do
      it 'return auth token header' do
        config = Cpaas::Config.new
        config.client_id = 'test-client-id'
        config.client_secret = 'test-client-secret'
        config.base_url = 'https://oauth-cpaas.att.com'

        api = Cpaas::Api.new(config)

        expect(api.auth_token).not_to be_nil
      end
    end
  end

  describe '#token_expired' do
    context 'when called' do
      before do
        config = Cpaas::Config.new
        config.client_id = 'test-client-id'
        config.client_secret = 'test-client-secret'
        config.base_url = 'https://oauth-cpaas.att.com'

        @api = Cpaas::Api.new(config)
      end

      it 'return false if token not expired' do
        expect(@api.token_expired).to eq(false)
      end

      it 'returns true if token expired' do
        allow(Time).to receive(:now).and_return(Time.now + 6*60*60)

        expect(@api.token_expired).to eq(true)
      end
    end
  end

  describe '#get_auth_token' do
    context 'when called with project credentials' do
      it 'generates valid body and url' do
        config = Cpaas::Config.new
        config.client_id = 'test-client-id'
        config.client_secret = 'test-client-secret'
        config.base_url = 'https://oauth-cpaas.att.com'

        url = '/cpaas/auth/v1/token'

        api = Cpaas::Api.new(config)
        response = api.get_auth_token

        expect(response[:__for_test__][:body]).to include('grant_type=client_credentials')
        expect(response[:__for_test__][:body]).to include('scope=openid')
        expect(response[:__for_test__][:body]).to include("client_id=#{config.client_id}")
        expect(response[:__for_test__][:body]).to include("client_secret=#{config.client_secret}")
        expect(response[:__for_test__][:url]).to eq(url)
      end
    end

    context 'when called with account credentials' do
      it 'generates valid body and url' do
        config = Cpaas::Config.new
        config.client_id = 'test-client-id'
        config.email = 'user@test.com'
        config.password = 'password'
        config.base_url = 'https://oauth-cpaas.att.com'

        url = '/cpaas/auth/v1/token'

        api = Cpaas::Api.new(config)
        response = api.get_auth_token

        expect(response[:__for_test__][:body]).to include('grant_type=password')
        expect(response[:__for_test__][:body]).to include('scope=openid')
        expect(response[:__for_test__][:body]).to include("client_id=#{config.client_id}")
        expect(response[:__for_test__][:body]).to include("username=#{CGI.escape(config.email)}")
        expect(response[:__for_test__][:body]).to include("password=#{config.password}")
        expect(response[:__for_test__][:url]).to eq(url)
      end
    end
  end
end
