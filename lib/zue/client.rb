require File.expand_path("../../zue", __FILE__)

module Zue
  class Client
    attr_reader :socket

    def initialize(address, context = nil)
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
end
