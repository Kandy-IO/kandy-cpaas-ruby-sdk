FILE_NAME = 'notifications.json'
DIR_NAME = "tmp"
PATH = "#{Dir.pwd}/#{DIR_NAME}/#{FILE_NAME}"

def error_message(error)
  "#{error[:name]}: #{error[:message]} (#{error[:exception_id]})"
end

def notifications
  return [] if !File.file?(PATH)

  all_notifications = JSON.parse(read_file)
  all_notifications[ENV['PHONE_NUMBER']]
end

def add_notification(notification)
  all_notifications = JSON.parse(read_file)

  all_notifications[ENV['PHONE_NUMBER']] = [] if all_notifications[ENV['PHONE_NUMBER']].nil?
  all_notifications[ENV['PHONE_NUMBER']].unshift(notification)

  write_file(all_notifications.to_json)
end

def read_file
  File.file?(PATH) ? File.read(PATH) : "{}"
end

def write_file(content)
  notification_file = File.file?(PATH) ? File.open(PATH, 'w') : File.new(PATH, 'w')

  notification_file.puts(content)
  notification_file.close
end

def initial_setup
  if !File.file?(PATH)
    dirname = File.dirname(Dir.pwd)
    unless File.directory?(DIR_NAME)
      FileUtils.mkdir_p(DIR_NAME)
    end

    notification_file = File.new(PATH, 'w')
    notification_file.puts("{}")
    notification_file.close
  end
end
