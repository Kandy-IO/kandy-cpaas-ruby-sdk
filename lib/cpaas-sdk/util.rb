def process_response(res, remove_outer_key = true)
  if res.key? :exception_id
    response = res
  elsif res && res.dig(:__for_test__)
    custom_body = res.dig(:custom_body)
    reject(res, :custom_body)

    if !res.dig(:custom_body).nil? && block_given?
      custom_body = yield res[:custom_body]
    end

    response = custom_body.nil? ? res : res.merge(custom_body)
  elsif block_given?
    response = yield res
  elsif remove_outer_key
    topLevelKey = res.keys.first
    response = res[topLevelKey].as_json
  else
    response = res
  end

  response
end

def compose_error_from(response)
  error_obj = deep_find(response, :message_id)

  if (error_obj)
    message = error_obj[:text]

    error_obj[:variables].each_with_index { |variable, index| message.gsub!("%#{index + 1}", variable) }

    return {
      name: error_obj[:name],
      exception_id: error_obj[:message_id],
      message: message
    }
  end


  {
    name: response[:error] || response.keys.first,
    message: response[:error_description] || response[:message]
  }
end

def id_from (url)
  url.split('/').last
end

def deep_find(object, key, parentKey = '')
  result = nil

  if object.respond_to?(:key?) && object.key?(key)
    object[:name] = parentKey
    return object
  elsif object.is_a? Enumerable
    object.each do |k, v|
      result = deep_find(v, key, k)

      return result if !result.nil?
    end
  end

  return result
end

def convert_hash_keys(value)
  case value
    when Array
      value.map { |v| convert_hash_keys(v) }
    when Hash
      Hash[value.map { |k, v| [underscore_key(k), convert_hash_keys(v)] }]
    else
      value
   end
end

def underscore_key(k)
  underscore(k.to_s).to_sym
end

def underscore(str)
  str.gsub(/::/, '/').
  gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
  gsub(/([a-z\d])([A-Z])/,'\1_\2').
  tr("-", "_").
  downcase
end

def reject(obj, key)
  obj.reject { |k,v| k == key }
end
