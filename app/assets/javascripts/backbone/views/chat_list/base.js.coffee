BSplendor.Views.ChatList = {}

class BSplendor.Views.ChatList.Base extends Backbone.View

  tagName: "ul"

  className: 'chat-list'

  template: JST["backbone/templates/chat_list/base"]

  initialize: ->
    @$el.addClass(@options.type)
    @collection.on('add', @addOne, @)
    @collection.on('remove', @render, @)

  render: =>
    @$el.children().remove()
    @collection.forEach(@addOne, @)
    this

  addOne: (chat)->
    chatView = new BSplendor.Views.Chat.Base(model: chat, collection: @collection)
    chatView.render()
    @$el.append chatView.el
    if @$el.parents(".panel-body").length > 0
      @$el.parents(".panel-body")[0].scrollTop = 10000

