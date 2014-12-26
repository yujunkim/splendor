class GamesController < ApplicationController
  skip_before_action :log_on, only: [:robot_play]

  def index
  end

  def run
    game = Game.find_by_id(params[:id])
    if game.players.first.is_robot
      game.host_with_port = request.host_with_port
      game.run
      render text: "running!"
    else
      render text: "not robot!"
    end

  end

  def robot_play
    game = Game.find_by_id(params[:id])
    if game.players.first.is_robot
      robot_player = game.players.first

      game.host_with_port = request.host_with_port
      game.action(robot_player, params)
    end

    render nothing: true
  end

end
