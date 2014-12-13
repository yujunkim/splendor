module CurrentUser
  def clear_current_user
    @current_user_provider = CurrentUserProvider.new({})
  end

  def log_on_user(user)
    current_user_provider.log_on_user(user,session,cookies)
  end

  def log_off_user
    current_user_provider.log_off_user(session,cookies)
  end

  def current_user
    current_user_provider.current_user(session,cookies)
  end

  def cookies
    request.cookie_jar
  end

  private

  def current_user_provider
    @current_user_provider ||= CurrentUserProvider.new(request.env)
  end
end
