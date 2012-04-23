require 'ffi-rzmq'

module Zue
  def self.context
    @context ||= ZMQ::Context.new
  end

  PING = 'PING'.freeze
  PONG = 'PONG'.freeze
end

