class GamesController < ApplicationController
  skip_before_action :log_on, only: [:robot_play]

  def index
  end

  def run
    game = Game.find_by_id(params[:id])
    if game.current_turn_user.robot
      game.request = request
      game.run
      render text: "running!"
    else
      render text: "not robot!"
    end

  end

  def robot_play
    game = Game.find_by_id(params[:id])
    if game.current_turn_user.robot
      robot_user = game.current_turn_user

      game.request = request
      game.action(robot_user, params)
    end

    render nothing: true
  end

end
