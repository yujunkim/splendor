class BSplendor.Models.Chat extends Backbone.Model
  events:
    purchase: "purchase"

  initialize: (options)->

  thumbnailColor: () ->
    if @get("user")
      @set(userColor: @get("user").get("color"))
      @get("user").get("color")
    else
      @get("userColor")

  username: () ->
    if @get("user")
      @set(userName: @get("user").get("name"))
      @get("user").get("name")
    else
      @get("userName")
