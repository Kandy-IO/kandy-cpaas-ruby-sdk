module Cpaas
  # @private

  class Config
    attr_accessor :client_id
    attr_accessor :client_secret
    attr_accessor :email
    attr_accessor :password
    attr_accessor :base_url

    def validate
      raise ArgumentError.new('`client_id` cannot be nil')  if client_id.nil?

      raise ArgumentError.new('`clientSecret` or `email/password` cannot be nil')  if client_secret.nil? && (email.nil? || password.nil?)

      true
    end
  end
end
