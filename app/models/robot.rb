class Robot
  require 'uri'
  require 'open-uri'

  def self.play(game_id)
    fork do
      game = Game.find_by_id(game_id)
      return unless game
      sleep(0.5)
      robot_user = game.current_turn_user
      begin
        client = ThriftClient.new(SplendorThrift::Player::Client, robot_user.home , retries: 2)
        action_result = client.play(
          GameSerializer.new(game, root: false, scope: robot_user).as_thrift
        )
      rescue ThriftClient::NoServersAvailable
        action_result = $thrift_client.play(
          GameSerializer.new(game, root: false, scope: robot_user).as_thrift
        )
      end

      params = action_result.as_json

      params["actionType"] = ActionType[params["actionType"]].camelize(:lower)

      if params["receiveJewelChipMap"]
        params["receiveJewelChipMap"] = Hash[params["receiveJewelChipMap"].map do |jewel_type, cost|
          [JewelType[jewel_type.to_i], cost.to_i]
        end]
      end

      if params["returnJewelChipMap"]
        params["returnJewelChipMap"] = Hash[params["returnJewelChipMap"].map do |jewel_type, cost|
          [JewelType[jewel_type.to_i], cost.to_i]
        end]
      end

      if action_result
        uri = URI.parse("http://localhost:5000/games/#{game_id}/robot_play")
        uri.query = params.to_query
        uri.open
      end
    end
  end

  def self.default_play_data(game_id)
    game = Game.find_by_id(game_id)
    return unless game.current_turn_user.robot
    robot_user = game.current_turn_user
    action_data = {}
    game.cards.where(revealed: true, user_id: nil).each do |card|
      if robot_user.purchasable?(card)
        action_data[:type] = "purchase_card"
        action_data[:d] = {
          card_id: card.id,
          return_jewel_chip_ids: robot_user.return_jewel_chips(card).map(&:id)
        }
        break
      end
    end

    if action_data.blank?
      receive_sample_jewel_ids = game.sample_jewel_chips.map(&:id)
      return_sample_jewel_ids = []
      after_receive_jewel_count = robot_user.jewel_chips.where(game_id: game.id).count + receive_sample_jewel_ids.count
      if after_receive_jewel_count > 10
        return_sample_jewel_ids = robot_user.jewel_chips.where(game_id: game.id).sample(after_receive_jewel_count - 10).map(&:id)
      end

      action_data[:type] = "receive_jewel_chip"
      action_data[:d] = {
        receive_jewel_chip_ids: receive_sample_jewel_ids,
        return_jewel_chip_ids: return_sample_jewel_ids
      }
    end

    action_data
  end
end
