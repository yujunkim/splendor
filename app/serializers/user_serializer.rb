class UserSerializer < Thriftify
  attributes :id,
             :name,
             :color,
             :robot,
             :lastGameId,
             :me,
             :playing

  def me
    !!(options[:scope] && options[:scope].id == id)
  end

  def lastGameId
    object.games.last.try(:id)
  end

  def playing
    !!options[:playing]
  end
end
