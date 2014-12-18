class GamesController < ApplicationController
  skip_before_action :log_on, only: [:robot_play]

  def index
  end

  def run
    game = Game.find_by_id(params[:id])
    return unless game.current_turn_user.robot
    game.request = request
    game.run

    render text: "running!"
  end

  def robot_play
    game = Game.find_by_id(params[:id])
    return unless game.current_turn_user.robot
    robot_user = game.current_turn_user

    game.request = request
    game.action(robot_user, params)

    render nothing: true
  end

end
