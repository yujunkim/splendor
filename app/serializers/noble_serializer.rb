class NobleSerializer < ActiveModel::Serializer
  attributes :id,
             :point,
             :userId,
             :costs

  def userId
    object.user_id
  end

  def costs
    {
      diamond: object.diamond,
      sapphire: object.sapphire,
      emerald: object.emerald,
      ruby: object.ruby,
      onyx: object.onyx
    }
  end
end
