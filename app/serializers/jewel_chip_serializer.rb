class JewelChipSerializer < Thriftify
  attributes :id,
             :jewelType

  def jewelType
    object.jewel_type
  end
end
