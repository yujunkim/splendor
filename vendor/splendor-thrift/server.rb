$:.push("gen-rb")

require 'thrift'

require 'player'
require 'pry'

class PlayerHandler
  def initialize()
  end

  def hi()
    puts "hi"
  end

  def play(game, id)
    binding.pry
  end

end

handler = PlayerHandler.new()
processor = SplendorThrift::Player::Processor.new(handler)
transport = Thrift::ServerSocket.new("localhost", 9090)
transportFactory = Thrift::FramedTransportFactory.new()
server = Thrift::SimpleServer.new(processor, transport, transportFactory)

puts "Starting the server..."
server.serve()
puts "done."
