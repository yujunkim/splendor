class UserSerializer < Thriftify
  attributes :id,
             :name,
             :color,
             :robot,
             :lastGameId,
             :me

  def me
    !!(options[:scope] && options[:scope].id == id)
  end

  def lastGameId
    object.games.last.try(:id)
  end
end
