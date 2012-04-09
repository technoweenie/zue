require File.expand_path("../../zue", __FILE__)

module Zue
  class Client
    attr_reader :socket, :servers, :ccf

    def initialize(ccf = IncrementingControlFrame.new, context = Zue.context)
      @context = context
      @socket = context.socket(ZMQ::ROUTER)
      @servers = []
      @ccf = ccf
    end

    def add_server(address)
      @socket.connect address
      @servers << address
    end

    def deliver(*messages)
      ccf = @ccf.next
      server = ping(ccf)
      request server, ccf, messages
    end

    def request(server, ccf, messages)
      @socket.send_strings([server, ccf, *messages])
    end

    def ping(ccf)
      @servers.each do |address|
        @socket.send_strings([address, ccf, PING])
      end
      client, ccf, *extra = receive_from_ccf(ccf)
      client
    end

    def receive_from_ccf(ccf)
      loop do
        @socket.recv_strings(list = [])
        return list if list[1] == ccf
      end
    end

    class IncrementingControlFrame
      def initialize
        @num = 0
      end

      def next
        (@num += 1).to_s
      end
    end
  end
end
