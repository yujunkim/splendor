class GameUpdateSerializer < ActiveModel::Serializer
  attributes :id,
             :currentTurnUserId,
             :userId,
             :hiredNoble,
             :purchasedCard,
             :reservedCard,
             :revealedCard,
             :receivedJewelChips,
             :returnedJewelChips

  def currentTurnUserId
    object.current_turn_user_id
  end

  def userId
    options[:scope].id
  end

  def hiredNoble
    return unless options[:hired_noble]
    NobleSerializer.new(options[:hired_noble], root: false)
  end

  def purchasedCard
    return unless options[:purchased_card]
    CardSerializer.new(options[:purchased_card], root: false)
  end

  def reservedCard
    return unless options[:reserved_card]
    CardSerializer.new(options[:reserved_card], root: false)
  end

  def revealedCard
    return unless options[:revealed_card]
    CardSerializer.new(options[:revealed_card], root: false)
  end

  def receivedJewelChips
    return [] unless options[:received_jewel_chips]
    options[:received_jewel_chips].map do |jewel_chip|
      JewelSerializer.new(jewel_chip, root: false)
    end
  end

  def returnedJewelChips
    return [] unless options[:returned_jewel_chips]
    options[:returned_jewel_chips].map do |jewel_chip|
      JewelSerializer.new(jewel_chip, root: false)
    end
  end
end
