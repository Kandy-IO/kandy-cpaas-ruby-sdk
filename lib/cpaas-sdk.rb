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
  # @param client_id [String] Private project key
  # @param client_secret [String] Private project secret
  # @param base_url [String] JSON URL of the server to be used.
  #
  # @example
  #   Cpaas.configure do |config|
  #     config.client_id: '<private project key>',
  #     config.client_secret: '<private project secret>',
  #     config.base_url: '<base url>'
  #   end
  #
  def self.configure
    yield self.config = Cpaas::Config.new

    config.validate

    self.api = Cpaas::Api.new(config)
  end
end
