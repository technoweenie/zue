# Zue

ZeroMQ Queue.  Rhymes with "queue".

Loosely based on the ZeroMQ [Freelance protocol](http://rfc.zeromq.org/spec:10).
Read the [rationale for the Freelance protocol](http://zguide.zeromq.org/page:all#toc86).

## Servers

```ruby
handler = lambda do |job|
  puts job.ccf
  job.messages.each { |msg| puts msg }
  puts
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
