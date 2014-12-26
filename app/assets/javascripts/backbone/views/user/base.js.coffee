BSplendor.Views.User = {}

class BSplendor.Views.User.Base extends Backbone.View

  className: 'user'

  template: JST["backbone/templates/user/base"]

  initialize: () ->
    @$el.addClass(@options.position)
    if @model.get("me")
      @$el.addClass("me")
    else
      @$el.addClass("others")
    @model.on 'reset-end', @render, @
    @model.on 'change', @render, @

  render: ->
    @$el.html(@template @)
