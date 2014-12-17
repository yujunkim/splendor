BSplendor.Views.StatField = {}

class BSplendor.Views.StatField.Base extends Backbone.View

  className: 'stat-field'

  template: JST["backbone/templates/stat_field/base"]

  initialize: () ->
    @model.on 'refresh', @render, @

  render: ->
    @$el.html(@template @)
    @$el.addClass("center-center font-size-6")

