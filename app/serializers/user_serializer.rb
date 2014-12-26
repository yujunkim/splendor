class UserSerializer < Thriftify
  attributes :id,
             :name,
             :photoUrl,
             :isMe,
             :isRobot

  def photoUrl
    object.photo_url
  end

  def isMe
    !!(options[:scope] && options[:scope].id == id)
  end
end
