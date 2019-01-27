# Rung

Rung is service object/business operation/Railway DSL, inspired by [Trailblazer Operation](http://trailblazer.to/gems/operation).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rung'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rung

## Example Usage

Example:
```ruby
class CreateOrder < Rung::Base
  step do |state|
    state[:order_id] = "order-#{SecureRandom.uuid }" 
  end
  step ValidateMagazineState
  step :log_start
  
  wrap WithBenchmark do
    step CreateTemporaryOrder
    step :place_order
  end
  
  step :log_success
  failure :log_failure
  
  def log_start(state)
    state[:logger].log("Creating order #{state[:order_id]}")
  end
  
  def log_success(state)
    state[:logger].log("Order #{state[:order_id]} created successfully")
  end
  
  def log_failure(state)
    state[:logger].log("Order #{state[:order_id]} not created")
  end
  
  def place_order(state)
    status = OrdersRepository.create(state[:order_id])
    
    # Step return value is important.
    # If step returns falsy value then the operation is considered as a failure.
    status == :success
  end
end

result = CreateOrder.call(logger: Rails.logger)
if result.success?
  print "Created order #{result[:order_id]}"
end
```

## Docs

Docs are available at https://gogiel.github.io/rung/.

They are generated from Cucumber specifications using [Cukedoctor](https://github.com/rmpestano/cukedoctor).

## Development

After checking out the repo, run `bundle` to install dependencies. Then, run `rake` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
