require File.expand_path("../helper", __FILE__)
require File.expand_path("../../lib/zue/push/server", __FILE__)
require File.expand_path("../../lib/zue/push/client", __FILE__)

class ZuePushTest < ZueTest
  setup_once do
    @address = "ipc://push-test"
    @server_address = @address + "-server-"

    @client = Zue::PushClient.new @address
  end


  def test_queues_between_servers
    server1 = Zue::PushServer.new @server_address + '1'
    server2 = Zue::PushServer.new @server_address + '2'
    @client.add_server server1.address
    @client.add_server server2.address

    msgs = [%w(a 1), %w(b 2)].each do |(a, b)|
      @client.deliver a, b
    end

    server1.handler = lambda do |job|
      assert_equal %w(a 1), job.messages
    end

    server2.handler = lambda do |job|
      assert_equal %w(b 2), job.messages
    end

    [server1, server2].map &:receive
  end

  def test_graceful_shutdown
    messages = []
    server = Zue::PushServer.new @server_address do |job|
      messages << job.messages
    end

    @client.add_server server.address

    thread = Thread.new { server.perform }
    sleep 0.1 # give #perform enough time before #close is called

    @client.deliver 'a'

    assert server.close

    @client.deliver 'b'

    thread.join

    assert_equal %w(a b), messages.flatten
  end
end
