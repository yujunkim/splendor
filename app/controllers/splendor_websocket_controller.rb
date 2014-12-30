class SplendorWebsocketController < WebsocketRails::BaseController
  include ActionView::Helpers::SanitizeHelper
  include CurrentUser

  def user_msg(ev, msg)
    time = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    Splendor::Application::Messages << {
      user: current_user,
      text: msg,
      time: time
    }

    broadcast_message ev, userId: current_user.id,
                          userName: current_user.name,
                          userPhotoUrl: current_user.photo_url,
                          received: time,
                          text: ERB::Util.html_escape(msg)
  end

  def setting
    if message.has_key?(:robotify)
      current_user.is_robot = !!message[:robotify]
      current_user.home = message[:home]
      current_user.players.each do |player|
        player.is_robot = current_user.is_robot
        player.home = current_user.home
      end
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
        UserSerializer.new(c.user, scope: connection.user, root: false, playing: playing_user_ids.include?(c.user.id))
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
    game = Game.new(message)
    return unless game
    users = game.players.map(&:user).compact
    WebsocketRails.users.each do |connection|
      if users.include?(connection.user)
        connection.send_message(
          :start_game, game: GameSerializer.new(game, scope: connection.user, root: false)
        )
      end
    end
    game.host_with_port = request.host_with_port
    #game.run if game.players.first.is_robot
  end

  def restart_game
    game = current_user.players.last.game
    send_message :start_game, game: GameSerializer.new(game, scope: current_user, root: false) if game
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
    game = Game.find_by_id(message[:gameId])
    game.action(game.players.first, message)
  end

  def login
    current_user.add_facebook_user message[:facebook_user]
    update_users
    user_msg :new_message, "joined chat room"
  end

  def client_connected
  end

  def client_disconnected
    update_users
    user_msg :new_message, "left chat room"
  end
end
