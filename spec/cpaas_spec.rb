require 'spec_helper'

RSpec.describe Cpaas do
  describe '.configure' do
    context 'when given a valid block' do
      it 'creates api' do
        stub_token

        Cpaas.configure do |config|
          config.client_id = 'client-id'
          config.client_secret = 'client-secret'
        end

        expect(Cpaas.api).to be_a Cpaas::Api
      end
    end
  end
end
