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
EVENTS +-----> MESSAGE PARSER      |  EXCHANGE  +-+         ...         |    ...
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

Exchange examines message *type*, *from*, and *to* fields, and decides whom this message addressed to. It then passes the message down to appropriate queue.

### Message queue

Each client connection handles by a Message Queue. It's a simple process that awaits messages from a queue and submits them to the client's socket. It also knows who was subscribed to the queue by managing a list of followers.

#### Virtual message queue

Some of the incoming events ask to subscribe a client to empty subscription (absent client). In this case we can spin up a virtual queue to keep common logic of the program untouched. Virtual queue is a dummy message queue that keeps list of followers and doesn't interact with a client.

## Usage

When in the root folder of the project, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. Then just start the server with default parameters:
```
./bin/message_broker
```
or say which ports you want to use:
```
./bin/message_broker 9090 9099
```

You can also run `bin/console` for an interactive prompt that will allow you to experiment. When in console you can start the server:
```
MessageBroker.start(event_port: 9090, client_port: 9099)
```
or instantiate an Exchange and play around:
```
e = MessageBroker::Exchange.new  
```
