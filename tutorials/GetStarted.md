# Get Started

In this quickstart, we will help you dip your toes in before you dive in. This guide will help you get started with the $KANDY$ Ruby SDK.

## Using the SDK

To begin, you will need to install the ruby library in your application. The library can be installed by using the following ways:

Add this line to your application's Gemfile:

```ruby
gem 'cpaas-sdk'
```

And then execute:

```bash
bundle
```

Or install it yourself as:
```bash
gem install cpaas-sdk
```

In your application, you simply need to create a new initializer `config/initializers/cpaas.rb`.

```ruby
# Call the configure method
Cpaas.configure do |config|
  # Configuration
end
```

After you've configured the SDK client, you can begin playing around with it to learn its functionality and see how it fits in your application. The API reference documentation will help to explain the details of the available features.

## Configuration

Before starting, you need to learn following information from your CPaaS account, specifically from Developer Portal.

If you want to authenticate using CPaaS account's credentials, the configuration information required should be under:

+ `Home` -> `Personal Profile` (top right corner) -> `Details`
> + `Email` should be mapped to `email`
> + Your account password should be mapped to `password`
> + `Account client ID` should be mapped to `client_id`

Alternatively if you want to use your project's credentials, the configuration information required should be under:

+ `Projects` -> `{your project}` -> `Project info`/`Project secret`
> + `Private Project key` should be mapped to `client_id`
> + `Private Project secret` should be mapped to `client_secret`

```ruby
Cpaas.configure do |config|
  config.client_id = '<private project key>'
  config.client_secret = '<private project secret>'
  config.base_url = 'https://$KANDYFQDN$'
end

# or

Cpaas.configure do |config|
  config.client_id = '<account client ID>'
  config.email = '<account email>'
  config.password = '<account password>'
  config.base_url = 'https://$KANDYFQDN$'
end
```

## Usage

All modules can be accessed via `Cpaas`, refer to [References](/developer/references/ruby) for details about all modules and it's methods. All method invocations follow the namespaced signature

`{Client}::{ModuleName}.{method_name}(params)`

Example:

```ruby
Cpaas::Conversation.create_message(params)
```

## Default Error Response

### Format

```ruby
{
  name: '<exception type>',
  exception_id: '<exception id/code>',
  message: '<exception message>'
}
```

### Example

```ruby
{
  name: 'serviceException',
  exception_id: 'SVC0002',
  message: 'Invalid input value for message part address'
}
```
