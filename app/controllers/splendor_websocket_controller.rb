class SplendorWebsocketController < WebsocketRails::BaseController
  include ActionView::Helpers::SanitizeHelper
  include CurrentUser

  def user_msg(ev, msg)
    WebsocketRails[:aaa_channel].trigger ev, userId: current_user.id,
                          userName: current_user.name,
                          userColor: current_user.color,
                          received: Time.now.strftime("%Y-%m-%d %H:%M:%S"),
                          text: ERB::Util.html_escape(msg)
  end

  def setting
    if message.has_key?(:robotfy)
      current_user.robot = !!message[:robotfy]
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
    WebsocketRails[:aaa_channel].subscribers.each do |connection|
      users = WebsocketRails[:aaa_channel].subscribers.map do |c|
        next if options[:except] && options[:except].id == c.user.id
        UserSerializer.new(c.user, scope: connection.user, root: false)
      end
      users.compact!

      connection.send_message :update_users, users
    end
  end

  def start_game
    game = Game.generate(connected_users)
    WebsocketRails[:aaa_channel].subscribers.each do |connection|
      connection.send_message(
        :start_game, GameSerializer.new(game, scope: connection.user)
      )
    end
  end

  def restart_game
    game = current_user.games.last
    send_message :start_game, GameSerializer.new(game, scope: current_user)
  end

  def new_message
    user_msg :new_message, message.dup
  end

  def game
    @game ||= Game.find(message[:game_id])
  end

  # message
  # {
  #   type: "purchase_card", "reserve_card", "receive_jewel"
  #   d: ...
  # }
  def action
    return unless ["purchase_card", "reserve_card", "receive_jewel"].include?(message[:type])
    options = game.send(message[:type], current_user, message[:d])
    game.after_action(current_user, message[:type], options)
  end


  def client_connected
    connection_store[:token] = current_user.auth_token
    user_msg :new_message, "joined chat room"
    update_users
  end

  def client_disconnected
    user_msg :new_message, "left chat room"
    update_users(except: current_user)
  end
end
