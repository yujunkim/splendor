window.initOperator = ->
  $("#login").remove()
  window.splendorController = new Splendor.Controller($(document.body).data("websocket-uri"), true);
  cf.reset() if cf?


window.Splendor = {}
window.Splendor.Users = {}

class Splendor.Controller
  constructor: (url,useWebSockets) ->
    @dispatcher = new WebSocketRails(url,useWebSockets)
    @dispatcher.on_open = @ready
    @dispatcher.on_error = @closed
    @bindEvents()

  bindEvents: =>
    @dispatcher._conn.on_close = ->
      if @dispatcher && @dispatcher._conn == @
        close_event = new WebSocketRails.Event(['connection_closed', event])
        @dispatcher.state = 'disconnected'
        splendorController.closed()
        @dispatcher.dispatch close_event
    @dispatcher.bind "connection_closed", @closed
    @dispatcher.bind 'new_message', @newMessage
    @dispatcher.bind 'start_game', @gameStarted
    @dispatcher.bind 'update_users', @updateUsers

  getUser: (id) ->
    Splendor.Users[id]

  addUser: (userHash) ->
    user = new BSplendor.Models.User(userHash)
    Splendor.Users[user.get("id")] = user
    Splendor.Me = user if user.get("isMe")
    user

  removeUser: (id) ->
    delete Splendor.Users[id]

  ready: ()=>
    @dispatcher.trigger 'login', facebook_user: window.facebookUser
    window.operator = new BSplendor.Models.Operator(splendorController: @)
    ov = new BSplendor.Views.Operator.Base(model: operator)
    ov.render()
    if window.game
      delete(game)
      $(document.body).find(".game-view").remove()
    $(document.body).find(".operator").remove()
    $(document.body).append(ov.el)

  closed: ()=>
    swal
      title: "서버와 연결이 끊어졌습니다."
      text: "다시 연결합니다."
      type: "error"
      confirmButtonColor: "#DD6B55"
      confirmButtonText: "OK"
      closeOnConfirm: false
    , =>
      @dispatcher.reconnect()
      swal "Success", "", "success"
      return

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
    console.log options
    @channel = @dispatcher.subscribe("game#{options.game.id}")
    @dispatcher.trigger "channel_subscribed", "game#{options.game.id}"
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
    game.gameOver(message.winnerId)

  action: (data) =>
    @dispatcher.trigger "action", $.extend(data, gameId: game.id)

  newMessage: (message) =>
    window.operator.newMessage(message) if window.operator
