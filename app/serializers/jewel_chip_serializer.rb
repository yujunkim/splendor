class JewelChipSerializer < Thriftify
  attributes :id,
             :userId,
             :jewelType

  def userId
    object.user_id
  end

  def jewelType
    object.jewel_type
  end
end
