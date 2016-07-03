# MessageBroker

This gem implements message broker which aims to pass messages from single event source to a number of clients. A diagram bellow shows logical structure of the program and message flow from the event source through to a client.

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


### Dispatcher

Dispatcher manages income connections as well as income messages. When new client arrives it creates new message queue and runs it in a separate thread. That way all the message queues are separated and can be processed in parallel.

When there is a new message it needs to be parsed, and checked to meet the sequence. If there is a gap between message's sequence number and last handled sequence, the message will be put on hold to process later in line order.

### Exchange

Exchange examines message type, from, and to fields, and decides whom this message addressed to. It then pass the message down to appropriate queue.

### Message queue

Each client connection handles by a Message Queue. It's a simple process that waits messages from queue and pass them over to client's socket.

#### Virtual message queue

Some of the incoming events ask to subscribe a client to nonexistent subscription (nonexistent client). In this case we can spin up a virtual queue to keep common logic of the program untouched. Virtual queue is a dummy message queue that keeps list of followers and doesn't connect to any client.

## Usage

When in the root folder of the project, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. Then just start the server with default parameters:
```
./bin/message_broker
```
or say which ports you want to use:
```
./bin/message_broker 9090 9099
```

You can also run `bin/console` for an interactive prompt that will allow you to experiment. When in console you can instantiate an Exchange:
```
  e = MessageBroker::Exchange.new
```
or start the server:
```
  MessageBroker.start(event_port: 9090, client_port: 9099)
```
and play around.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
