# Zue

ZeroMQ Queue.

## Servers

```ruby
resp = lambda do |job|
  puts job.ccf
  puts job.messages.join(", ")
end

server = Zue::Server.new 'tcp://127.0.0.1:5555', resp
server.receive; server.receive
```

## Clients

```ruby
client = Zue::Client.new
client.add_server 'tcp://127.0.0.1:5555'
client.add_server 'tcp://127.0.0.1:5556'

client.deliver "abc"
```
