class SplendorWebsocketController < WebsocketRails::BaseController
  def index
  end

  def join_game
    broadcast_message "join_game", {
      user_name:  connection_store[:user][:user_name],
      received:   Time.now.to_s(:short),
      msg_body:   'j game'
      }
  end

  def leave_game
  end
end
