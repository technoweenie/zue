require File.expand_path("../../zue", __FILE__)

module Zue
  class Server
    # Initializes a Server for handling jobs.  The default handler is a block,
    # or anything that responds to #call with a single Zue::Job.
    #
    #   # send a block
    #   server = Zue::Server.new "tcp://127.0.0.1:5555" do |job|
    #     puts "do work for #{job.messages.inspect}"
    #   end
    #
    #   # pass a block object
    #   handler = lambda do |job|
    #     puts "do work for #{job.messages.inspect}"
    #   end
    #
    #   server = Zue::Server.new("tcp://127.0.0.1:5555", handler)
    #
    #   # use a custom handler
    #   handler = MyCustomHandler.new
    #   server = Zue::Server.new("tcp://127.0.0.1:5555", handler)
    #
    # address - An accessible String ZMQ address.
    # handler - Optional Block handler.
    # context - Optional ZMQ::Context.
    #
    def initialize(address, handler = nil, context = Zue.context)
      @address = address
      @context = context
      @handler = handler || (block_given? ? Proc.new : nil)
      @socket = context.socket(ZMQ::ROUTER)
      @socket.identity = address
      @socket.bind address
    end

    # Public: Gets the public address of the server socket.
    #
    # Returns a String ZMQ address.
    attr_reader :address

    # Public: Gets the ZMQ Router socket for the server.
    #
    # Returns a ZMQ::Socket.
    attr_reader :socket

    # Public: Gets or sets the block that handles incoming requests.
    #
    # Returns a Block that takes a single Zue::Job argument.
    attr_accessor :handler

    # Public: Begins the work loop.  Constantly listens for and responds to
    # messages.
    #
    # Returns nothing.
    def perform
      loop { receive }
    end

    # Public: Blocks until a message is received, and handles it.
    #
    # Returns nothing.
    def receive
      rc = @socket.recv_strings(list = [])
      if ZMQ::Util.resultcode_ok?(rc)
        client = list.shift
        ccf = list.shift
        if list[0] == PING
          handle_ping(client, ccf)
        else
          job = Job.new(client, ccf, list)
          handle_job(job)
        end
      else
        puts ZMQ::Util.error_string
      end
    end

    # Public: Closes the ZMQ Socket.
    #
    # Returns nothing.
    def close
      @socket.close
    end

    # Responds to a ping.
    #
    # client - String ZMQ identity for the client socket.
    # ccf    - The String client control frame.
    #
    # Returns nothing.
    def handle_ping(client, ccf)
      @socket.send_strings [client, ccf, PONG]
    end

    # Passes the job to the server's handler.
    #
    # job - A Zue::Job.
    #
    # Returns nothing.
    def handle_job(job)
      @handler.call job
    end
  end
end

