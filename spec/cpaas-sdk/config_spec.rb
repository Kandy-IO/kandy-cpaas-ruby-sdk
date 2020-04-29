require 'spec_helper'

RSpec.describe Cpaas::Config do
  describe '.validate' do
    context 'when all instance variables are nil' do
      it 'throws error' do
        config = Cpaas::Config.new

        expect { config.validate }.to raise_error(ArgumentError, '`client_id` cannot be nil')
      end
    end

    context 'when only client_id is set' do
      it 'throws error' do
        config = Cpaas::Config.new
        config.client_id = 'test-client-id'

        expect { config.validate }.to raise_error(ArgumentError, '`clientSecret` or `email/password` cannot be nil')
      end
    end

    context 'when client_id and email are set' do
      it 'throws error' do
        config = Cpaas::Config.new
        config.client_id = 'test-client-id'
        config.email = 'test@email.com'

        expect { config.validate }.to raise_error(ArgumentError, '`clientSecret` or `email/password` cannot be nil')
      end
    end

    context 'when client_id and password are set' do
      it 'throws error' do
        config = Cpaas::Config.new
        config.client_id = 'test-client-id'
        config.password = 'test-password'

        expect { config.validate }.to raise_error(ArgumentError, '`clientSecret` or `email/password` cannot be nil')
      end
    end

    context 'when client_id, email and password are set' do
      it 'returns true' do
        config = Cpaas::Config.new
        config.client_id = 'test-client-id'
        config.email = 'test@email.com'
        config.password = 'test-password'

        expect(config.validate).to eq(true)
      end
    end

    context 'when client_id and client_secret are set' do
      it 'returns true' do
        config = Cpaas::Config.new
        config.client_id = 'test-client-id'
        config.client_secret = 'test-client-secret'

        expect(config.validate).to eq(true)
      end
    end
  end
end
