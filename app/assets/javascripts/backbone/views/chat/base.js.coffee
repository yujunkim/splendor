BSplendor.Views.Chat = {}

class BSplendor.Views.Chat.Base extends Backbone.View

  tagName: "li"

  className: 'chat-view'

  template: JST["backbone/templates/chat/base"]

  initialize: () ->

  render: ->
    @$el.html(@template @)
    clearInterval(@interval) if @interval
    @timeTicking()
    @interval = setInterval(@timeTicking, 1000);


  timeTicking: =>
    @$el.find(".clock").html(moment(@model.get("received")).fromNow())
