$:.push(Rails.root + "vendor/splendor-thrift/gen-rb")
require 'thrift'

require 'splendor_ai'
require 'pry'

class ThriftSplendorAiHandler
  def initialize()
  end

  def purchasable?(me, card)
    card.costs.map do |jewel_type, cost|
      card_count = me.purchasedCards[jewel_type].count
      jewel_chip_count = me.jewelChips[jewel_type].count
      card_count + jewel_chip_count >= cost
    end.uniq == [true]
  end

  def actual_cost(me, card)
    costs = {}
    card.costs.each do |jewel_type, cost|
      card_count = me.purchasedCards[jewel_type].count
      costs[jewel_type] = cost - card_count
      costs[jewel_type] = 0 if costs[jewel_type] < 0
    end
    costs
  end

  def sample_receive_jewel_chip_map(game)
    exist_jewel_chips = {}
    game.centerField.jewelChips.each do |jewel_type, jewel_chips|
      if jewel_type != SplendorThrift::JewelType::GOLD && jewel_chips.present?
        exist_jewel_chips[jewel_type] = jewel_chips
      end
    end

    if exist_jewel_chips.count > 2
      Hash[exist_jewel_chips.keys.sample(3).map do |sample_jewel_type|
        [sample_jewel_type, 1]
      end]
    else
      map = nil
      exist_jewel_chips.keys.shuffle.each do |jewel_type|
        map = { jewel_type => 2 } if exist_jewel_chips[jewel_type].count >= 4
      end

      if map.nil?
        map = Hash[exist_jewel_chips.keys.map do |jewel_type|
          [jewel_type, 1]
        end]
      end

      map
    end
  end

  def sample_return_jewel_chip_map(me, count)
    jewel_chip_map = {}
    returnable_jewel_chips = me.jewelChips.select do |jewel_type, jewel_chips|
      jewel_type != SplendorThrift::JewelType::GOLD
    end.values.flatten
    returnable_jewel_chips.sample(count).each do |jewel_chip|
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
    me = game.players.first
    action_result = SplendorThrift::ActionResult.new

    game.centerField.cards[SplendorThrift::CardLocation::EXHIBITION].each do |card_grade, cards|
      cards.each do |card|
        if purchasable?(me, card)
          action_result.actionType = SplendorThrift::ActionType::PURCHASE_CARD
          action_result.cardId = card.id
          action_result.returnJewelChipMap = actual_cost(me, card)
          break
        end
      end
      break if action_result.actionType
    end

    if action_result.actionType.nil?
      action_result.actionType = SplendorThrift::ActionType::RECEIVE_JEWEL_CHIP
      action_result.receiveJewelChipMap = sample_receive_jewel_chip_map(game)

      after_receive_jewel_count = me.jewelChips.values.flatten.count +
        action_result.receiveJewelChipMap.map{|jewel_chip, count| count}
                                         .inject{|sum,x| sum + x }.to_i

      if after_receive_jewel_count > 10
        action_result.returnJewelChipMap =
          sample_return_jewel_chip_map(me, (after_receive_jewel_count - 10))
      end
    end

    action_result
  end
end
