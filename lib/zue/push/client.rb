require File.expand_path("../../client", __FILE__)

module Zue
  # Simple client using a ZeroMQ PUSH socket to distribute jobs to a set of
  # PULL servers using simple Fair Queueing.
  class PushClient < Client
    def build_socket(address)
      super(address, ZMQ::PUSH)
    end
  end
end

