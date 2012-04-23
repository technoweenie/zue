require File.expand_path("../../client", __FILE__)

module Zue
  # Experimental client using a ROUTER sockets and the Freelance pattern.
  class FreelanceClient < Client
    attr_reader :servers, :ccf
    def initialize(address, ccf = nil, context = nil)
      super(address, context)
      @ccf = ccf || IncrementingControlFrame.new
      @servers = []
    end

    # Public
    def add_server(address)
      super(address)
      @servers << address
    end

    # Public
    def deliver(*messages)
      ccf = @ccf.next
      server = ping(ccf)
      request server, ccf, messages
    end

    # Public
    def build_socket(address)
      super(address, ZMQ::ROUTER)
    end

    def request(server, ccf, messages)
      @socket.send_strings([server, ccf, *messages])
    end

    def ping(ccf)
      @servers.each do |address|
        @socket.send_strings([address, ccf, PING])
      end
      receive_from_ccf(ccf).first
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

      # Public
      def next
        (@num += 1).to_s
      end
    end
  end
end
