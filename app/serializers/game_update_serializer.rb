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
    options[:user].id
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
