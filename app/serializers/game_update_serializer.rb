class GameUpdateSerializer < ActiveModel::Serializer
  attributes :id,
             :currentTurnPlayerId,
             :playerId,
             :turnCount,
             :hiredNoble,
             :purchasedCard,
             :reservedCard,
             :revealedCard,
             :receivedJewelChips,
             :returnedJewelChips

  def currentTurnPlayerId
    object.players.first.id
  end

  def playerId
    object.players.last.id
  end

  def hiredNoble
    return unless options[:hired_noble]
    NobleSerializer.new(options[:hired_noble], options.slice(:root, :scope))
  end

  def purchasedCard
    return unless options[:purchased_card]
    CardSerializer.new(options[:purchased_card], options.slice(:root, :scope))
  end

  def reservedCard
    return unless options[:reserved_card]
    CardSerializer.new(options[:reserved_card], options.slice(:root, :scope))
  end

  def revealedCard
    return unless options[:revealed_card]
    CardSerializer.new(options[:revealed_card], options.slice(:root, :scope))
  end

  def receivedJewelChips
    return [] unless options[:received_jewel_chips]
    options[:received_jewel_chips].map do |jewel_chip|
      JewelChipSerializer.new(jewel_chip, options.slice(:root, :scope))
    end
  end

  def returnedJewelChips
    return [] unless options[:returned_jewel_chips]
    options[:returned_jewel_chips].map do |jewel_chip|
      JewelChipSerializer.new(jewel_chip, options.slice(:root, :scope))
    end
  end
end
