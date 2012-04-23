require File.expand_path("../../server", __FILE__)

module Zue
  class FreelanceServer < Server
    Job = Struct.new(:sender, :ccf, :messages)

    # Public
    def build_socket(address)
      super(address, ZMQ::ROUTER)
    end

    # Public
    def receive_message(list)
      client = list.shift
      ccf = list.shift

      if list[0] == PING
        handle_ping(client, ccf)
      else
        handle_job(Job.new(client, ccf, list))
      end
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
  end
end
