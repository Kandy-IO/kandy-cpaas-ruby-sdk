## createClient

Ruby SDK

Instantiate the instance with client\_id & client\_secret.

### Parameters:

* **client_id** (String) - Private project secret
* **client_secret** (String) — Private project secret
* **base_url** (String) — JSON URL of the server to be used

### Example:

```ruby
Cpaas.configure do |config|
  config.client_id = '<private project key>'
  config.client_secret = '<private project secret>'
  config.base_url = '<base url>'
end
```