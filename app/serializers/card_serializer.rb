class CardSerializer < Thriftify
  attributes :id,
             :userId,
             :cardGrade,
             :jewelType,
             :point,
             :costs,
             :revealed,
             :reserved

  def revealed
    @revealed ||= !!(object.revealed || (options[:scope] && options[:scope].id == object.user_id))
  end

  def userId
    object.user_id
  end

  def cardGrade
    object.card_grade
  end

  def jewelType
    return unless revealed
    object.jewel_type
  end

  def costs
    return unless revealed
    {
      diamond: object.diamond,
      sapphire: object.sapphire,
      emerald: object.emerald,
      ruby: object.ruby,
      onyx: object.onyx
    }
  end

  def point
    return unless revealed
    object.point
  end
end
