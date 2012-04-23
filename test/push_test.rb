require File.expand_path("../helper", __FILE__)
require File.expand_path("../../lib/zue/push/server", __FILE__)
require File.expand_path("../../lib/zue/push/client", __FILE__)

class ZuePushTest < ZueTest
  setup_once do
    @address = "ipc://push-test"
    @server_address = @address + "-server-"

    @client = Zue::PushClient.new @address
    @server1 = Zue::PushServer.new @server_address + '1'
    @server2 = Zue::PushServer.new @server_address + '2'
    @client.add_server @server1.address
    @client.add_server @server2.address
  end

  teardown_once do
    @server.close
    @socket.close
  end

  def test_queues_between_servers
    msgs = [%w(a 1), %w(b 2)].each do |(a, b)|
      @client.deliver a, b
    end

    @server1.handler = lambda do |job|
      assert_equal %w(a 1), job.messages
    end

    @server2.handler = lambda do |job|
      assert_equal %w(b 2), job.messages
    end

    [@server1, @server2].map &:receive
  end
end
