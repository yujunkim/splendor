class CardSerializer < Thriftify
  attributes :id,
             :cardGrade,
             :jewelType,
             :point,
             :costs,
             :revealed

  def revealed
    @revealed ||= !!(object.revealed || mine)
  end

  def mine
    player_mine = object.player && options[:player] && options[:player].id == object.player.id

    scope_mine = object.player && object.player.user && options[:scope] && options[:scope].id == object.player.user.id

    player_mine || scope_mine
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
    object.costs
  end

  def point
    return unless revealed
    object.point
  end
end
