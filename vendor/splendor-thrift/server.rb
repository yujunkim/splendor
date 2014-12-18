$:.push("gen-rb")

require 'thrift'

require 'player'
require 'pry'

class PlayerHandler
  def initialize()
  end

  def purchasable?(game, my_id, card)
    card.costs.map do |jewel_type, cost|
      card_count = game.cards.select do |game_card|
                     game_card.userId == my_id &&
                     game_card.jewelType == jewel_type &&
                     !game_card.reserved
                   end.count
      jewel_chip_count = game.jewelChips.select do |game_jewel_chip|
                           game_jewel_chip.userId == my_id &&
                           game_jewel_chip.jewelType == jewel_type
                         end.count
      card_count + jewel_chip_count >= cost
    end.uniq == [true]
  end

  def actual_cost(game, my_id, card)
    costs = {}
    card.costs.each do |jewel_type, cost|
      card_count = game.cards.select do |game_card|
                     game_card.userId == my_id &&
                     game_card.jewelType == jewel_type &&
                     !game_card.reserved
                   end.count
      costs[jewel_type] = cost - card_count
      costs[jewel_type] = 0 if costs[jewel_type] < 0
    end
    costs
  end

  def sample_receive_jewel_chip_map(game)
    jewel_chip_map = {}
    game.jewelChips.each do |game_jewel_chip|
      if game_jewel_chip.userId.nil? && game_jewel_chip.jewelType != SplendorThrift::JewelType::GOLD
        jewel_chip_map[game_jewel_chip.jewelType] ||= 0
        jewel_chip_map[game_jewel_chip.jewelType] += 1
      end
    end

    if jewel_chip_map.count > 2
      Hash[jewel_chip_map.keys.sample(3).map do |sample_jewel_type|
             [sample_jewel_type, 1]
           end]
    else
      { jewel_chip_map.keys.sample => 2 }
    end
  end

  def sample_return_jewel_chip_map(game, my_id, count)
    jewel_chip_map = {}
    game.jewelChips.select{|jewel_chip| jewel_chip.userId == my_id}.sample(count).each do |jewel_chip|
      jewel_chip_map[jewel_chip.jewelType] ||= 0
      jewel_chip_map[jewel_chip.jewelType] += 1
    end
    jewel_chip_map
  end

  def hi()
    puts "hi"
  end

  def play(game)
    puts "play!"
    my_id = game.currentTurnUserId
    action_result = SplendorThrift::ActionResult.new

    game.cards.select{|card| card.revealed && card.userId.nil?}.each do |card|
      if purchasable?(game, my_id, card)
        action_result.actionType = SplendorThrift::ActionType::PURCHASE_CARD
        action_result.cardId = card.id
        action_result.returnJewelChipMap = actual_cost(game, my_id, card)
        break
      end
    end

    if action_result.actionType.nil?
      action_result.actionType = SplendorThrift::ActionType::RECEIVE_JEWEL_CHIP
      action_result.receiveJewelChipMap = sample_receive_jewel_chip_map(game)

      after_receive_jewel_count =
        game.jewelChips.select{|jewel_chip| jewel_chip.userId == my_id}.count +
        action_result.receiveJewelChipMap.map{|jewel_chip, count| count}
                                         .inject{|sum,x| sum + x }

      if after_receive_jewel_count > 10
        action_result.returnJewelChipMap =
          sample_return_jewel_chip_map(game, my_id, (after_receive_jewel_count - 10))
      end
    end

    action_result
  end

end

def thrift_server_start
  handler = PlayerHandler.new()
  processor = SplendorThrift::Player::Processor.new(handler)
  transport = Thrift::ServerSocket.new("localhost", 9090)
  transportFactory = Thrift::FramedTransportFactory.new()
  server = Thrift::SimpleServer.new(processor, transport, transportFactory)

  puts "Starting the server..."
  server.serve()
  puts "done."
end
