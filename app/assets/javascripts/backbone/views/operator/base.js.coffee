BSplendor.Views.Operator = {}

class BSplendor.Views.Operator.Base extends Backbone.View

  events:
    "click #send": "sendMessage"
    "click #start": "startGame"
    "click #restart": "restartGame"
    "click #rename": "rename"
    "click #recolor": "recolor"
    "click #robotify": "robotify"
    "keypress #message": "messageKeypressed"
    "mouseenter .operation-dropdown": "dropdownMouseentered"
    "mouseleave .operation-dropdown": "dropdownMouseleaved"

  template: JST["backbone/templates/operator/base"]

  initialize: () ->
    @$el.attr("id", "chat")
    $(window).on "user-updated", @updateUser

  messageKeypressed: (e)->
    @sendMessage(e) if e.keyCode == 13
    $('#send').on 'click', @sendMessage

  startGame: ->
    splendorController.dispatcher.trigger 'start_game'

  restartGame: ->
    splendorController.dispatcher.trigger 'restart_game'

  rename: ->
    name = prompt("set rename")
    debugger
    if name?
      "hi"
      #splendorController.dispatcher.trigger 'setting', username: name

  recolor: ->
    splendorController.dispatcher.trigger 'setting', color: true

  robotify: ->
    splendorController.dispatcher.trigger 'setting', robotify: true

  sendMessage: (e) =>
    e.preventDefault()
    messageEl = @$el.find('#message')
    message = messageEl.val()
    splendorController.dispatcher.trigger 'new_message', message
    messageEl.val('')

  render: ->
    @$el.html(@template @)
    chatListView = new BSplendor.Views.ChatList.Base
      collection: @model.chatList,
    chatListView.render()
    @$el.find(".panel-body").append(chatListView.el)

  dropdownMouseentered: (e)->
    el = $(e.currentTarget)
    unless el.hasClass("open")
      el.find(".dropdown-toggle").dropdown('toggle')

  dropdownMouseleaved: (e)->
    el = $(e.currentTarget)
    if el.hasClass("open")
      el.find(".dropdown-toggle").dropdown('toggle')

  usersTemplate: ()->
    el = []
    _.each Dic.user, (user, userId) ->
      userTemplate = $(JST["backbone/templates/operator/user"](user))
      el.push(userTemplate)
    el

  updateUser: () =>
    if @$el? && @$el.find("#users")?
      @$el.find("#users").empty()
      @$el.find("#users").append(@usersTemplate())


