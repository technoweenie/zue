require 'test/unit'
require 'running_man'

class ZueTest < Test::Unit::TestCase
  def self.setup_once(&block)
    self.block = RunningMan::Block.new(&block)
  end

  def self.final_teardowns
    @final_teardowns ||= []
  end

  class << self
    attr_accessor :block
  end

  def setup
    self.class.block.run(self)
  end
end

RunningMan.setup_on ZueTest

