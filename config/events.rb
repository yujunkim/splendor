WebsocketRails::EventMap.describe do

  [
    :setting,
    :update_users,
    :start_game,
    :restart_game,
    :new_message,
    :client_connected,
    :client_disconnected,
    :channel_subscribed,
    :action
  ].each{|method| subscribe method, to: SplendorWebsocketController, with_method: method}
end
