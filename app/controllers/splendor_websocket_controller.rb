class SplendorWebsocketController < WebsocketRails::BaseController
  include ActionView::Helpers::SanitizeHelper
  include CurrentUser

  def user_msg(ev, msg)
    broadcast_message ev, userId: current_user.id,
                          userName: current_user.name,
                          userColor: current_user.color,
                          received: Time.now.strftime("%Y-%m-%d %H:%M:%S"),
                          text: ERB::Util.html_escape(msg)
  end

  def setting
    if message.has_key?(:robotify)
      current_user.robot = !!message[:robotify]
      current_user.home = message[:home]
      current_user.save
      update_users
    elsif message.has_key?(:username)
      current_user.name = message[:username]
      current_user.save
      update_users
    elsif message.has_key?(:color)
      current_user.fill_sample_color
      current_user.save
      update_users
    end
  end

  def update_users
    playing_user_id_hash = Hash[WebsocketRails.channel_tokens.keys.map do |key|
      user_ids = WebsocketRails[key].subscribers.map{|x| x.user.id}
      [key, user_ids]
    end]
    playing_user_ids = playing_user_id_hash.values.flatten
    WebsocketRails.users.each do |connection|
      users = WebsocketRails.users.map do |c|
        UserSerializer.new(c.user.reload, scope: connection.user.reload, root: false, playing: playing_user_ids.include?(c.user.id))
      end
      users.compact!

      connection.send_message :update_users, users
    end
  end

  def channel_subscribed
    update_users
  end

  # {
  #   user_ids: [],
  #   robot_count: 0
  # }
  def start_game
    game = Game.generate(message)
    return unless game
    WebsocketRails.users.each do |connection|
      if game.users.include?(connection.user)
        connection.send_message(
          :start_game, GameSerializer.new(game, scope: connection.user)
        )
      end
    end
    game.request = request
    game.run if game.current_turn_user.robot
  end

  def restart_game
    game = current_user.games.last
    send_message :start_game, GameSerializer.new(game, scope: current_user) if game
  end

  def new_message
    user_msg :new_message, message.dup
  end

  # message
  # {
  #   type: "purchase_card", "reserve_card", "receive_jewel_chip"
  #   d: ...
  # }
  def action
    game = Game.find(message[:gameId])
    game.request = request
    game.action(current_user, message)
  end


  def client_connected
    connection_store[:token] = current_user.auth_token
    update_users
    user_msg :new_message, "joined chat room"
  end

  def client_disconnected
    update_users
    user_msg :new_message, "left chat room"
  end
end
