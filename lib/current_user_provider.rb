class CurrentUserProvider
  TOKEN_COOKIE = "_splendor"
  CURRENT_USER_KEY ||= "_CURRENT_USER"

  # do all current user initialization here
  def initialize(env)
    @env = env
    @request = Rack::Request.new(env)
  end

  # our current user, return nil if none is found
  def current_user(session = nil, cookies = nil)
    return @env[CURRENT_USER_KEY] if @env.key?(CURRENT_USER_KEY)

    request = Rack::Request.new(@env)

    id = request.cookies[TOKEN_COOKIE]

    current_user = nil

    if id && id.length == 40
      current_user = User.find_by_id(id)
    end

    if current_user.nil?
      current_user = User.new
      cookies.permanent[TOKEN_COOKIE] = { value: current_user.id, httponly: true }
    end

    @env[CURRENT_USER_KEY] = current_user
  end

  # log on a user and set cookies and session etc.
  def log_on_user(user, session, cookies)
    cookies.permanent[TOKEN_COOKIE] = { value: user.id, httponly: true }
    @env[CURRENT_USER_KEY] = user
  end

  # we may need to know very early on in the middleware if an auth token
  # exists, to optimize caching
  def has_auth_cookie?
    request = Rack::Request.new(@env)
    cookie = request.cookies[TOKEN_COOKIE]
    !cookie.nil? && cookie.length == 40
  end

  def log_off_user(session, cookies)
    cookies[TOKEN_COOKIE] = nil
  end
end
