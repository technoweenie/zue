require File.expand_path("../../helper", __FILE__)
require File.expand_path("../../../lib/zue/freelance/server", __FILE__)

class ZueFreelanceServerTest < ZueTest
  setup_once do
    @address = "ipc://server-test"
    @server = Zue::FreelanceServer.new(@address)

    @socket = Zue.context.socket(ZMQ::ROUTER)
    @socket.identity = 'server-test-worker'
    @socket.connect @address

    sleep 0.5
  end

  teardown_once do
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

