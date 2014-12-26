class Robot
  require 'uri'
  require 'open-uri'

  def self.play(game)
    fork do
      sleep(0.1)
      robot_player = game.players.first
      action_result = nil
      begin
        if robot_player.home
          client = ThriftClient.new(SplendorThrift::Player::Client, robot_player.home , retries: 2)
          action_result = client.play(
            GameSerializer.new(game, root: false, scope: robot_player).as_thrift
          )
        end
      rescue ThriftClient::NoServersAvailable
        Rails.logger.debug("NoServersAvailable")
      end

      if action_result.blank?
        action_result = ThriftSplendorAiHandler.new.play(
          GameSerializer.new(game, root: false, player: robot_player).as_thrift
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
        uri = URI.parse("http://#{game.host_with_port}/games/#{game.id}/robot_play")
        uri.query = params.to_query
        10.times do
          begin
            uri.open
            break
          rescue
          end
        end
      end
    end
  end

end
