require 'spec_helper'

RSpec.describe Cpaas::Twofactor do
  before do
    stub_token

    Cpaas.configure do |config|
      config.client_id = 'client-id'
      config.client_secret = 'client-secret'
      config.base_url = 'https://oauth-cpaas.att.com'
    end

    @base_url = "/cpaas/auth/v1/#{Cpaas.api.user_id}"
  end

  describe '.send_code' do
    before do
      stub("#{@base_url}/codes", :post, {
        code: {
          resourceURL: '/cpaas/auth/v1/91fc8907-d336-4707-ad3c-0711c0b87471/codes/51b545e7-729f-4690-9571-e5c85852b179'
        }
      })
    end

    context 'when given only required params' do
      it 'generates valid body and url' do
        params = {
          destination_address: '123',
          message: 'test-message'
        }

        expected_body = {
          code: {
            address: ['123'],
            method: 'sms',
            format: {
              length: 6,
              type: 'numeric'
            },
            expiry: 120,
            message: 'test-message'
          }
        }.to_json

        response = Cpaas::Twofactor.send_code(params)

        expect(response[:__for_test__][:body]).to eq(expected_body)
        expect(response[:__for_test__][:url]).to eq("#{@base_url}/codes")
      end
    end

    context 'when given optional params' do
      it 'generates valid body and url' do
        params = {
          destination_address: '123',
          message: 'test-message',
          type: 'alphanumeric',
          expiry: 360,
          method: 'email',
          subject: 'test'
        }

        expected_body = {
          code: {
            address: ['123'],
            method: 'email',
            format: {
              length: 6,
              type: 'alphanumeric'
            },
            expiry: 360,
            subject: 'test',
            message: 'test-message'
          }
        }.to_json

        response = Cpaas::Twofactor.send_code(params)

        expect(response[:__for_test__][:body]).to eq(expected_body)
        expect(response[:__for_test__][:url]).to eq("#{@base_url}/codes")
      end
    end
  end

  describe '.resend_code' do
    before do
      @code_id = '123'

      stub("#{@base_url}/codes/#{@code_id}", :put)
    end

    context 'when given only required params' do
      it 'generates valid body and url' do
        params = {
          code_id: @code_id,
          destination_address: '123',
          message: 'test-message'
        }

        expected_body = {
          code: {
            address: ['123'],
            method: 'sms',
            format: {
              length: 6,
              type: 'numeric'
            },
            expiry: 120,
            message: 'test-message'
          }
        }.to_json

        response = Cpaas::Twofactor.resend_code(params)

        expect(response[:__for_test__][:body]).to eq(expected_body)
        expect(response[:__for_test__][:url]).to eq("#{@base_url}/codes/#{@code_id}")
      end
    end

    context 'when given optional params' do
      it 'generates valid body and url' do
        params = {
          code_id: @code_id,
          destination_address: '123',
          message: 'test-message',
          type: 'alphanumeric',
          expiry: 360,
          method: 'email',
          subject: 'test'
        }

        expected_body = {
          code: {
            address: ['123'],
            method: 'email',
            format: {
              length: 6,
              type: 'alphanumeric'
            },
            expiry: 360,
            subject: 'test',
            message: 'test-message'
          }
        }.to_json

        response = Cpaas::Twofactor.resend_code(params)

        expect(response[:__for_test__][:body]).to eq(expected_body)
        expect(response[:__for_test__][:url]).to eq("#{@base_url}/codes/#{@code_id}")
      end
    end
  end

  describe '.verify_code' do
    context 'when given valid params' do
      it 'generates valid url and body' do
        code_id = 'code-id'
        url = "#{@base_url}/codes/#{code_id}/verify"
        params = {
          code_id: code_id,
          verification_code: '12345'
        }

        expected_body = {
          code: {
            verify: '12345'
          }
        }.to_json

        stub(url, :put)

        response = Cpaas::Twofactor.verify_code(params)

        expect(response[:__for_test__][:body]).to eq(expected_body)
        expect(response[:__for_test__][:url]).to eq(url)
      end
    end
  end

  describe '.delete_code' do
    context 'when given valid params' do
      it 'generates valid url' do
        code_id = '12345'
        params = {
          code_id: code_id
        }

        stub("#{@base_url}/codes/#{code_id}", :delete)

        response = Cpaas::Twofactor.delete_code(params)

        expect(response[:__for_test__][:url]).to eq("#{@base_url}/codes/#{code_id}")
      end
    end
  end
end