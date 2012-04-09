require File.expand_path("../../zue", __FILE__)

module Zue
  class Server
    attr_reader :address, :socket

    def initialize(address, responder = nil, context = Zue.context)
      @address = address
      @context = context
      @responder = responder || Proc.new
      @socket = context.socket(ZMQ::ROUTER)
      @socket.identity = address
      @socket.bind address
    end

    def perform
      loop { receive }
    end

    def receive
      rc = @socket.recv_strings(list = [])
      if ZMQ::Util.resultcode_ok?(rc)
        client = list.shift
        ccf = list.shift
        if list[0] == PING
          receive_ping(client, ccf)
        else
          job = Job.new(client, ccf, list)
          receive_job(job)
        end
      else
        puts ZMQ::Util.error_string
      end
    end

    def receive_ping(client, ccf)
      @socket.send_strings [client, ccf, PONG]
    end

    def receive_job(job)
      @responder.call job
    end
  end
end

