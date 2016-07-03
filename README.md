# MessageBroker

This gem implements message broker which aims to pass messages from single event source
to a number of clients. A diagram bellow shows logical structure of the program and message flow from the event source through to a client.

```
Fig 1
        +------------------------- MESSAGE BROKER ----------------------+
        |                                                               |
        |  +-------- DISPATCHER -----------+        +-----------------+ |
        |  |                               |      +-> MESSAGE QUEUE 1 +--> CLIENT 1
        |  |   THREAD MANAGEMENT   +-------+----+ | +-----------------+ |
        |  |   NETWORK MANAGEMENT  |            | |                     |
EVENTS +-----> MESSAGE PARSER      |  EXCHANGE  +-+         ...         |
        |  |   SEQUENCE HANDLER    |            | |                     |
        |  |                       +-------+----+ | +-----------------+ |
        |  |                               |      +-> MESSAGE QUEUE N +--> CLIENT N
        |  +-------------------------------+        +-----------------+ |
        |                                                               |
        +---------------------------------------------------------------+


```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'message_broker'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install message_broker

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/message_broker.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
