require 'test/unit'
require File.expand_path("../../lib/zue/server", __FILE__)

class ZueServerTest < Test::Unit::TestCase
  def setup
    @address = "ipc://server-test"
    @server = Zue::Server.new(@address)
    @socket = Zue.context.socket(ZMQ::ROUTER)

    @socket.connect @address
    sleep 0.2
  end

  def teardown
    @server.close
    @socket.close
  end

  def test_handle_request
    rc = @socket.send_strings [@address, '1', 'hi']
    assert_equal 0, rc

    called = false

    @server.handler = lambda do |job|
      called = true
      assert_equal '1', job.ccf
      assert_equal ['hi'], job.messages
    end

    @server.receive
    assert called
  end

  def test_ping
    rc = @socket.send_strings [@address, '1', 'PING']
    assert_equal 0, rc

    @server.receive

    rc = @socket.recv_strings(list = [])
    assert_equal 0, rc

    assert_equal '1', list[1]
    assert_equal "PONG", list[2]
  end
end

