class JewelSerializer < ActiveModel::Serializer
  attributes :id,
             :userId,
             :type

  def userId
    object.user_id
  end

  def type
    object.jewel_type
  end
end
