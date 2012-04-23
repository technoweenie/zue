require File.expand_path("../../zue", __FILE__)

module Zue
  class Client
    attr_reader :socket

    def initialize(address, ccf = nil, context = nil)
      @context = context || Zue.context
      @socket = build_socket(address)
    end

    # Public
    def add_server(address)
      @socket.connect(address)
    end

    # Public
    def deliver(*messages)
      @socket.send_strings(messages)
    end

    # Public
    def build_socket(address, socket_type)
      socket = @context.socket(socket_type)
      socket.identity = address
      socket
    end

    # Public
    def close
      @socket.close
    end
  end

  # Simple client using a ZeroMQ PUSH socket to distribute jobs to a set of
  # PULL servers using simple Fair Queueing.
  class PushClient < Client
    def build_socket(address)
      super(address, ZMQ::PUSH)
    end
  end

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
      @socket.connect address
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
        puts "SENDING #{address.inspect} #{ccf.inspect}"
        @socket.send_strings([address, ccf, PING])
      end
      receive_from_ccf(ccf).first
    end

    def receive_from_ccf(ccf)
      loop do
        puts 'loopy loopy'
        rc = @socket.recv_strings(list = [])
        puts "RC: #{rc.inspect} // #{list.inspect}"
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
