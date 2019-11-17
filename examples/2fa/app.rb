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
    redirect '/login'
  end

  get '/login' do
    # If user is logged in and trying to access login page, redirect to dashboard.
    return redirect '/dashboard' if is_logged_in? session

    set_default_state(session)

    erb :login, layout: :index
  end

  post '/login' do
    if valid_credentials? params
      # If login credentials are valid, send_code method is used to request 2FA code
      # to the phone number as destination_address.
      #
      # If a valid response is received, the code_id present in the response is set in the session.
      # This code_id is eventually used when the 2FA code (received in the phone number) needs to be verified.
      # Once the code_id is set, the user is redirected to the code verification page
      # where the user is prompted to enter the code received in the phone number.
      #
      # If an error is raised by send_code, it is caught in the catch block and the user is
      # redirected to the login page with the received error message as an alert.

      response = Cpaas::Twofactor.send_code({
        destination_address: ENV['PHONE_NUMBER'],
        message: 'Your verification code: {code}'
        })

      if response[:exception_id]
        # Here something went wrong either with the server or proper parameters were not passed.
        # Received error message is echoed back to the UI as error alert.
        return erb :login, layout: :index, locals: { alert: { message: error_message(response), type: 'error' } }
      end

      session[:code_id] = response[:code_id]
      set_credentials_verified(session)

      redirect '/verify'
    else
      # If login credentials do not match with credentials present in .env, login page is re-rendered with error alert
      erb :login, layout: :index, locals: { alert: { message: 'Invalid username or password', type: 'error' } }
    end
  end

  get '/verify' do
    # If logged in and trying to access login page, redirect to dashboard.
    return redirect '/dashboard' if is_logged_in? session
    # If login credentials are not verified but tries to access the code verification page, user is redirected.
    return redirect '/logout' if !is_credentials_verified? session

    # If the login credentials are verified, user is shown code verification page.
    erb :verify, layout: :index, locals: { alert: { message: "Verification code has been sent to #{ENV['PHONE_NUMBER']}", type: 'success' } }
  end

  post '/verify' do
     # The 2FA code entered in the UI is passed to the verify_code along with codeId,
     # which was saved from the response of send_code method.
     #
     # There are two valid response for verify_code method.
     #
     # Type 1 - The 2FA code is successfully verified.
     # {
     #  verified: true,
     #  message: 'Verified'
     # }
     #
     # Type 2 - The 2FA code pass is either incorrect or the code has expired
     # (The expiry of the code can be changed by passing expiry param in the send_code. Ref - Documentation)
     # {
     #  verified: false,
     #  message: 'Code expired or invalid'
     # }

    response = Cpaas::Twofactor.verify_code({
      code_id: session[:code_id],
      verification_code: params['code']
    })

    if response[:exception_id]
      # Here something went wrong either with the server or proper parameters were not passed.
      # Received error message is echoed back to the UI as error alert.
      return erb :verify, layout: :index, locals: { alert: { message: error_message(response), type: 'error' } }
    end

    if response[:verified]
      login session
      # The code is verified and redirected to dashboard/portal/protected area of app.
      return redirect '/dashboard'
    else
      # The code is invalid and error message received from server is shown as error alert.
      return erb :verify, layout: :index, locals: { alert: { message: response[:message], type: 'error' } }
    end
  end

  get '/dashboard' do
    # If not logged in, redirected to logout.
    return redirect '/logout' if !is_logged_in? session

    # Login criteria is fulfilled, renders dashboard/portal/protected area of app
    erb :dashboard, layout: :index
  end

  get '/logout' do
    # Logged in session is cleared
    logout session

    redirect '/login'
  end
end
