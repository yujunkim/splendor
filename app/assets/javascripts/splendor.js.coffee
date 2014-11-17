$ ->
  window.splendorController = new Splendor.Controller($('#splendor').data('uri'), true);


window.Splendor = {}

class Splendor.User
  constructor: (@user_name) ->
  serialize: => { user_name: @user_name }

class Splendor.Controller
  constructor: (url,useWebSockets) ->
    @messageQueue = []
    @dispatcher = new WebSocketRails(url,useWebSockets)
    @dispatcher.on_open = @createUser
    @bindEvents()

  bindEvents: =>
    $('#door .join').on 'click', @joinGame
    @dispatcher.bind 'join_game', @newMessage
    #@dispatcher.bind 'user_list', @updateUserList
    #$('input#user_name').on 'keyup', @updateUserInfo
    #$('#send').on 'click', @sendMessage
    #$('#message').keypress (e) -> $('#send').click() if e.keyCode == 13

  createUser: =>
    rand_num = Math.floor(Math.random()*1000)
    @user = new Splendor.User("Guest_" + rand_num)
    @dispatcher.trigger 'new_user', @user.serialize()

  joinGame: =>
    @dispatcher.trigger 'join_game', @user.serialize()

  newMessage: (message) =>
    debugger
