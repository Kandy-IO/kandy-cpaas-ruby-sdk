## createClient

Ruby SDK

Instantiate the instance with client\_id & client\_secret.

### Parameters:

* **client_id** (String) - Private project key / Account client ID. If Private project key is used then client_secret is mandatory. If account client ID is used then email and password are mandatory.
* **client_secret** (String) — Private project secret
* **email** (String) — Account email address.
* **password** (String) — Account password
* **base_url** (String) — URL of the server to be used.

### Example:

```ruby
Cpaas.configure do |config|
  config.client_id = '<private project key>'
  config.client_secret = '<private project secret>'
  config.base_url = '<base url>'
end

# or

Cpaas.configure do |config|
  config.client_id = '<account client ID>'
  config.email = '<account email>'
  config.password = '<account password>'
  config.base_url = '<base url>'
end
```