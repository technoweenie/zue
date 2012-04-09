# Zue

ZeroMQ Queue.

## Servers

```ruby
handler = lambda do |job|
  puts job.ccf
  puts job.body
end

server = Zue::Server.new 'tcp://127.0.0.1:5555', handler
server.perform
```

## Clients

```ruby
client = Zue::Client.new
client.add_server 'tcp://127.0.0.1:5555'
client.add_server 'tcp://127.0.0.1:5556'

client.deliver "abc"
```
