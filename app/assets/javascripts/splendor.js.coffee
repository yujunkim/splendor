$ ->
  window.splendorController = new Splendor.Controller($(document.body).data("websocket-uri"), true);
  cf.reset() if cf?


window.Splendor = {}
window.Dic = {
  card: {},
  user: {},
  jewelChip: {},
  noble: {}
}

class Splendor.Controller
  constructor: (url,useWebSockets) ->
    @dispatcher = new WebSocketRails(url,useWebSockets)
    @dispatcher.on_open = @ready
    @bindEvents()

  bindEvents: =>
    @dispatcher.bind 'new_message', @newMessage
    @dispatcher.bind 'start_game', @gameStarted
    @dispatcher.bind 'update_users', @updateUsers

  getUser: (id) ->
    Dic.user[id]

  addUser: (userHash) ->
    user = new BSplendor.Models.User(userHash)
    Dic.user[user.get("id")] = user
    user

  ready: =>
    window.operator = new BSplendor.Models.Operator(splendorController: @)
    ov = new BSplendor.Views.Operator.Base(model: operator)
    ov.render()
    $(document.body).prepend(ov.el)

  updateUsers: (users) =>
    console.log users
    users.forEach (userHash) =>
      unless user = @getUser(userHash.id)
        user = @addUser(userHash)
      user.set(userHash)
    $(window).trigger("user-updated")

  gameStarted: (options)=>
    @channel = @dispatcher.subscribe("game#{options.game.id}")
    @dispatcher.bind 'action_performed', @actionPerformed

    window.game = new BSplendor.Models.Game(options)
    gv = new BSplendor.Views.Game.Base(model: game)
    gv.render()
    $(document.body).prepend(gv.el)
    $('#start').off 'click'
    $('#start').remove()
    $('#restart').off 'click'
    $('#restart').remove()

  actionPerformed: (message)=>
    console.log message
    game.actionPerformed(message.type, message.d)

  action: (type, data) =>
    @dispatcher.trigger "action", {
      game_id: game.id,
      type: type,
      d: data
    }

  newMessage: (message) =>
    window.operator.newMessage(message) if window.operator
