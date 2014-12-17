class GamesController < ApplicationController
  skip_before_action :log_on, only: [:default_robot_play_data, :robot_play]

  def index
  end

  def default_robot_play_data
    action_data = Robot.default_play_data(params[:id])
    render json: action_data
  end

  def robot_play
    game = Game.find_by_id(params[:id])
    return unless game.current_turn_user.robot
    robot_user = game.current_turn_user
    data = params[:d] || {}
    type = params[:type]

    game.action(robot_user, {type: type, d: data})

    render nothing: true
  end

end
