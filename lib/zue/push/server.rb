require File.expand_path("../../server", __FILE__)

module Zue
  class PushServer < Server
    def build_socket(address)
      super(address, ZMQ::PULL)
    end

    # Public
    def receive_message(list)
      handle_job(Job.new(nil, nil, list))
    end
  end
end
