require File.expand_path("../../server", __FILE__)

module Zue
  class PushServer < Server
    Job = Struct.new(:messages)

    def build_socket(address)
      super(address, ZMQ::PULL)
    end

    # Public
    def receive_message(list)
      handle_job(Job.new(list))
    end
  end
end
