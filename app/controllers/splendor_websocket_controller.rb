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

  def update_users(options = {})
    WebsocketRails.users.each do |connection|
      users = WebsocketRails.users.map do |c|
        next if options[:except] && options[:except].id == c.user.id
        UserSerializer.new(c.user.reload, scope: connection.user.reload, root: false)
      end
      users.compact!

      connection.send_message :update_users, users
    end
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
    Robot.play(game.id) if game.current_turn_user.robot
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
