class Robot
  require 'uri'
  require 'open-uri'

  def self.play(game)
    fork do
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
        request = game.request
        uri = URI.parse("http://#{request.host_with_port}/games/#{game.id}/robot_play")
        uri.query = params.to_query
        uri.open
      end
    end
  end

end
