BSplendor.Views.ZoomField = {}

class BSplendor.Views.ZoomField.Base extends Backbone.View

  className: 'zoom-field'

  template: JST["backbone/templates/zoom_field/base"]

  initialize: () ->
    @model.on 'refresh', @render, @

  render: ->
    @$el.html(@template @)
    switch @model.get("type")
      when "card"
        view = new BSplendor.Views.Card.Base
          model: @model.get("instance")
        view.render()
        @$el.append(view.el)
      when "noble"
        view = new BSplendor.Views.Noble.Base
          model: @model.get("instance")
        view.render()
        @$el.append(view.el)
      when "jewelChipList"
        collection = @model.get("instance")
        collection.models.forEach (model) =>
          view = new BSplendor.Views.JewelChip.Base
            model: model
          view.render()
          @$el.append(view.el)
      when "packCardList"
        collection = @model.get("instance")
        @$el.append(JST["backbone/templates/zoom_field/pack_card_list"](collection))
      when "user"
        model = @model.get("instance")
        @$el.append(JST["backbone/templates/zoom_field/user"](model))


