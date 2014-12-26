((d, s, id) ->
  js = undefined
  fjs = d.getElementsByTagName(s)[0]
  return  if d.getElementById(id)
  js = d.createElement(s)
  js.id = id
  js.src = "//connect.facebook.net/ko_KR/sdk.js"
  fjs.parentNode.insertBefore js, fjs
  return
) document, "script", "facebook-jssdk"

window.fbAsyncInit = ->
  FB.init
    appId: "542101129259820"
    cookie: true
    xfbml: true
    version: "v2.2"

  checkLoginState()

# This is called with the results from from FB.getLoginStatus().
statusChangeCallback = (response) ->
  console.log "statusChangeCallback"
  console.log response

  # The response object is returned with a status field that lets the
  # app know the current login status of the person.
  # Full docs on the response object can be found in the documentation
  # for FB.getLoginStatus().
  if response.status is "connected"

    # Logged into your app and Facebook.
    testAPI()
  else if response.status is "not_authorized"

    # The person is logged into Facebook, but not your app.
    document.getElementById("status").innerHTML = "Please log " + "into this app."
  else

    # The person is not logged into Facebook, so we're not sure if
    # they are logged into this app or not.
    document.getElementById("status").innerHTML = "Please log " + "into Facebook."

# This function is called when someone finishes with the Login
# Button.  See the onlogin handler attached to it in the sample
# code below.
checkLoginState = ->
  FB.getLoginStatus (response) ->
    statusChangeCallback response

# enable cookies to allow the server to access
# the session

# Now that we've initialized the JavaScript SDK, we call
# FB.getLoginStatus().  This function gets the state of the
# person visiting this page and can return one of three states to
# the callback you provide.  They can be:
#
# 1. Logged into your app ('connected')
# 2. Logged into Facebook, but not your app ('not_authorized')
# 3. Not logged into Facebook and can't tell if they are logged into
#    your app or not.
#
# These three cases are handled in the callback function.

# Load the SDK asynchronously

# Here we run a very simple test of the Graph API after login is
# successful.  See statusChangeCallback() for when this call is made.
testAPI = ->
  console.log "Welcome!  Fetching your information.... "
  FB.api "/me", (response) ->
    window.facebookUser = response
    $("#status").append("Thanks for logging in, " + response.name + "!")
    $("#status").append("<image src='http://graph.facebook.com/#{response.id}/picture?type=square'/>")
    window.initOperator()
