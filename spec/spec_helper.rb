require 'bundler/setup'
require 'cpaas-sdk'
require 'webmock/rspec'

# WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

def stub(url, verb, custom_body = nil)
  base_url = 'https://oauth-cpaas.att.com'
  request_url = base_url + url

  stub_request(verb, request_url)
    .with(body: /.*/)
    .to_return(lambda do |request|
      request_body = {
        __for_test__: {
          body: request.body,
          headers: request.headers.to_json, # .to_json to prevent the keys from converting into snake_case
          url: request.uri.path
        }
      }

      request_body = request_body.merge({ custom_body: custom_body }) if !custom_body.nil?

      return {
        body: request_body.to_json
      }
    end)
end

def stub_token
  access_token_payload = {
    iat: (Time.now - 2 * 60 * 60).to_i,
    exp: (Time.now + 4 * 60 * 60).to_i
  }

  id_token_payload = {
    preferred_username: 'test-user'
  }

  secret = 'test-secret'

  access_token = JWT.encode(access_token_payload, secret, 'HS256')
  id_token = JWT.encode(id_token_payload, secret, 'HS256')

  body = {
    access_token: access_token,
    id_token: id_token
  }

  stub('/cpaas/auth/v1/token', :post, body)
end
