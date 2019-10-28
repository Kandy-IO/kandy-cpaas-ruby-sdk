def valid_credentials?(params)
  ENV['EMAIL'] == params['email'] && ENV['PASSWORD'] == params['password']
end

def error_message(error)
  "#{error[:name]}: #{error[:message]} (#{error[:exception_id]})"
end

def set_credentials_verified(session)
  session[:credentials_verified] = true
  session[:code_verified] = false
end

def is_credentials_verified?(session)
  session[:credentials_verified] && !session[:code_verified]
end

def is_logged_in?(session)
  session[:credentials_verified] && session[:code_verified]
end

def logout(session)
  session[:credentials_verified] = true
  session[:code_verified] = false
  session[:code_id] = nil
end

def set_default_state(session)
  session[:credentials_verified] = false
  session[:code_verified] = false
end


def login(session)
  session[:credentials_verified] = true
  session[:code_verified] = true
end
