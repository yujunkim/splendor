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

  thumbnailUrl: () ->
    if @get("user")
      @set(userPhotoUrl: @get("user").get("photoUrl"))
      @get("user").get("photoUrl")
    else
      @get("userPhotoUrl")

  username: () ->
    if @get("user")
      @set(userName: @get("user").get("name"))
      @get("user").get("name")
    else
      @get("userName")

  userId: () ->
    if @get("user")
      @set(userId: @get("user").get("id"))
      @get("user").get("id")
    else
      @get("userId")
