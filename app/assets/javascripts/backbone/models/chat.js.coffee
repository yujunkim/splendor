class BSplendor.Models.Chat extends Backbone.Model
  events:
    purchase: "purchase"

  initialize: (options)->

  me: ()=>
    @get("user").me
