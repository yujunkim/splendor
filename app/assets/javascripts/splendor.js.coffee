$ ->
  window.splendorController = new Splendor.Controller($(document.body).data("websocket-uri"), true);
  cf.reset() if cf?


window.Splendor = {}
window.Splendor.Users = {}

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
    Splendor.Users[id]

  addUser: (userHash) ->
    user = new BSplendor.Models.User(userHash)
    Splendor.Users[user.get("id")] = user
    Splendor.Me = user if user.get("me")
    user

  removeUser: (id) ->
    delete Splendor.Users[id]

  ready: ()=>
    window.operator = new BSplendor.Models.Operator(splendorController: @)
    ov = new BSplendor.Views.Operator.Base(model: operator)
    ov.render()
    $(document.body).prepend(ov.el)

  updateUsers: (users) =>
    totalUserIds = _.map Splendor.Users, (user, id) => user.get("id")
    users.forEach (userHash) =>
      unless user = @getUser(userHash.id)
        user = @addUser(userHash)
      user.set(userHash)
      totalUserIds = _.without(totalUserIds, user.get("id"))
    totalUserIds.forEach (removedUserId) =>
      @removeUser(removedUserId)
    $(window).trigger("user.updated")

  gameStarted: (options)=>
    @channel = @dispatcher.subscribe("game#{options.game.id}")
    @dispatcher.bind 'action_performed', @actionPerformed
    @dispatcher.bind 'game_over', @gameOver

    window.game = new BSplendor.Models.Game(options.game)
    gv = new BSplendor.Views.Game.Base(model: game)
    gv.render()
    $(document.body).prepend(gv.el)
    $("#game-door").remove()

  actionPerformed: (message)->
    console.log message
    game.actionPerformed(message.type, message.d)

  gameOver: (message)->
    console.log message
    game.gameOver(message.winner)

  action: (data) =>
    @dispatcher.trigger "action", $.extend(data, gameId: game.id)

  newMessage: (message) =>
    window.operator.newMessage(message) if window.operator
