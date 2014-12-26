BSplendor.Views.Operator = {}

class BSplendor.Views.Operator.Base extends Backbone.View

  events:
    "click #send": "sendMessage"
    "click #start": "startGame"
    "click #cancel-start": "cancelStartGame"
    "click #restart": "restartGame"
    "click #robotify": "robotify"
    "keypress #message": "messageKeypressed"
    "click .list-group .list-group-item": "toggleActive"
    "click .list-arrows .arrow": "arrowClicked"
    "keyup .search": "search"
    "click .number-spinner .sign": "numberSpinnerSignClicked"

  className: "operator"

  doorTemplate: JST["backbone/templates/operator/door"]
  chatTemplate: JST["backbone/templates/operator/chat"]
  userTemplate: JST["backbone/templates/operator/user"]

  initialize: () ->
    $(window).on "user.updated", @updateUser

  messageKeypressed: (e)->
    @sendMessage(e) if e.keyCode == 13
    $('#send').on 'click', @sendMessage

  cancelStartGame: ->
    @$el.find("#game-door").removeClass("invite-mode")

  startGame: ->
    gameDoor = @$el.find("#game-door")
    if gameDoor.hasClass("invite-mode")
      robotCount = parseInt(@$el.find("#robot-count").val())
      robotCount = 0 if robotCount == NaN
      userIds = []
      @$el.find("#participants").find("li.user").each () ->
        userIds.push $(@).data("id")
      if 2 <= userIds.length + robotCount  <= 4
        splendorController.dispatcher.trigger 'start_game', {robot_count: robotCount, user_ids: userIds}
    else
      @$el.find("#game-door").addClass("invite-mode")

  restartGame: ->
    splendorController.dispatcher.trigger 'restart_game'

  robotify: ->
    home = null
    if !Splendor.Me.get("isRobot")
      home = prompt("set robot's home")
      home = null if home == ""
    splendorController.dispatcher.trigger 'setting', robotify: !Splendor.Me.get("isRobot"), home: home

  sendMessage: (e) =>
    e.preventDefault()
    messageEl = @$el.find('#message')
    message = messageEl.val()
    splendorController.dispatcher.trigger 'new_message', message
    messageEl.val('')

  render: ->
    @$el.append(@doorTemplate @).append(@chatTemplate @)
    chatListView = new BSplendor.Views.ChatList.Base
      collection: @model.chatList,
    chatListView.render()
    @$el.find(".panel-body").append(chatListView.el)
    @$el.find("#robotify").addClass("active") if Splendor.Me && Splendor.Me.get("isRobot")

  usersTemplate: ()->
    el = []
    _.each Splendor.Users, (user, userId) =>
      userTemplate = $(@userTemplate user)
      el.push(userTemplate)
    el

  updateUser: () =>
    if @$el? && @$el.find("#chat")?
      @$el.find("#chat .user-list").empty()
      @$el.find("#chat .user-list").append(@usersTemplate())
    if @$el? && @$el.find("#game-door")?
      @$el.find("#game-door .user-list.user-list-base").empty()
      @$el.find("#game-door .user-list.user-list-base").append(@usersTemplate())

    @$el.find("#robotify").removeClass("active")
    @$el.find("#robotify").addClass("active") if Splendor.Me && Splendor.Me.get("isRobot")

  toggleActive: (e)->
    $(e.currentTarget).toggleClass "active"

  arrowClicked: (e)->
    btn = $(e.currentTarget)
    actives = ""
    if btn.attr("data-dir") is "left"
      actives = $(".list-right ul li.active")
      actives.clone().removeClass("active").appendTo ".list-left ul"
      actives.remove()
    else if btn.attr("data-dir") is "right"
      actives = $(".list-left ul li.active")
      actives.clone().removeClass("active").appendTo ".list-right ul"
      actives.remove()

  search: (e) ->
    code = e.keyCode or e.which
    return if code is "9"
    searchElem = $(e.currentTarget)
    searchElem.val null  if code is "27"
    listElems = searchElem.parents(".dual-list").find(".list-group li")
    val = $.trim(searchElem.val()).replace(RegExp(" +", "g"), " ").toLowerCase()
    listElems.show().filter(->
      text = $(@).text().replace(/\s+/g, " ").toLowerCase()
      not ~text.indexOf(val)
    ).hide()

  numberSpinnerSignClicked: (e) ->
    btn = $(e.currentTarget)
    oldValue = btn.closest(".number-spinner").find("input").val().trim()
    newVal = 0
    if btn.attr("data-dir") is "up"
      newVal = parseInt(oldValue) + 1
    else
      newVal = parseInt(oldValue) - 1

    if newVal < 0
      newVal = 0
    else if newVal > 3
      newVal = 3
    btn.closest(".number-spinner").find("input").val newVal
