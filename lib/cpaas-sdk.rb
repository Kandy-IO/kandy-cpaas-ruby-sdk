require 'cpaas-sdk/api'
require 'cpaas-sdk/config'
require 'cpaas-sdk/resources'
require 'cpaas-sdk/version'

module Cpaas
  class << self
    attr_accessor :config, :api
  end

  #
  # Configure the SDK with client_id and client_secret.
  #
  # @param client_id [String] Private project key / Account client ID. If Private project key is used then client_secret is mandatory. If account client ID is used then email and password are mandatory.
  # @param base_url [String] URL of the server to be used.
  # @param client_secret [String] +optional Private project secret
  # @param email [String] +optional Account login email
  # @param password [String] +optional Account login password
  #
  # @example
  #   Cpaas.configure do |config|
  #     config.client_id = '<private project key>'
  #     config.client_secret = '<private project secret>'
  #     config.base_url = 'https://$KANDYFQDN$'
  #   end
  #
  #   # or
  #
  #   Cpaas.configure do |config|
  #     config.client_id = '<account client ID>'
  #     config.email = '<account email>'
  #     config.password = '<account password>'
  #     config.base_url = 'https://$KANDYFQDN$'
  #   end

  def self.configure
    yield self.config = Cpaas::Config.new

    config.validate

    self.api = Cpaas::Api.new(config)
  end
end
