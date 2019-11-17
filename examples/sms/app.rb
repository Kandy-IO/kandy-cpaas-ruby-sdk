require 'sinatra'
require 'json'
require 'pry'
require 'cpaas-sdk'

require './helper'

class App < Sinatra::Application
  enable :sessions

  def initialize
    super

    # Initialize
    Cpaas.configure do |config|
      config.client_id = ENV['CLIENT_ID']
      config.client_secret = ENV['CLIENT_SECRET']
      config.base_url = ENV['BASE_URL']
    end
  end

  get '/' do
    type = params['success'] ? 'success' : 'error'
    message = params[type]

    erb :index, locals: { alert: { message: message, type: type } }
  end

  post '/send' do
    #
    # The method create_message would send an sms when the 'type' attribute is 'SMS'
    #
    response = Cpaas::Conversation.create_message({
      type: Cpaas::Conversation.types[:SMS],
      destination_address: params['number'],
      message: params['message'],
      sender_address: ENV['PHONE_NUMBER']
    })

    puts response

    return redirect "/?error=#{error_message(response)}" if response[:exception_id]

    redirect '/?success=Success'
  end

  post '/subscribe' do
    #
    # The subscribe method would enable a notification subscription for a purchased number (destination) and the
    # webhook_url is the public POST endpoint where notifications would be received. For this exable the
    # '/webhook' endpoint is enabled for the incoming notification.
    #

    response = Cpaas::Conversation.subscribe({
      type: Cpaas::Conversation.types[:SMS],
      destination_address: ENV['PHONE_NUMBER'],
      webhook_url: "#{params['webhook']}/webhook"
    })

    puts response

    return redirect "/?error=#{error_message(response)}" if response[:exception_id]

    redirect '/?success=Created subscription'
  end

  post '/webhook' do
    body = JSON.parse request.body.read

    #
    # The Cpaas::Notification.parse will parse the received notification and will return a
    # simplified version of th notification to consume
    #

    notification = Cpaas::Notification.parse(body)

    add_notification(notification) # Helper method, check helper.rb

    status 200
  end

  get '/notifications' do
    content_type :json
    notifications.to_json # Helper method, check helper.rb
  end
end
