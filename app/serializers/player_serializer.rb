class PlayerSerializer < Thriftify
  attributes :id,
             :color,
             :isRobot,
             :isChief,
             :isMe

  attributes :purchasedCards,
             :reservedCards,
             :jewelChips,
             :nobles,
             :user

  def purchasedCards
    Hash[object.purchased_cards.map do |jewel_type, cards|
      [jewel_type, cards.map{|card| CardSerializer.new(card, options)}]
    end]
  end

  def reservedCards
    object.reserved_cards.map{|card| CardSerializer.new(card, options)}
  end

  def jewelChips
    Hash[object.jewel_chips.map do |jewel_type, jewel_chips|
      [jewel_type, jewel_chips.map{|jewel_chip| JewelChipSerializer.new(jewel_chip, options)}]
    end]
  end

  def nobles
    object.nobles.map{|noble| NobleSerializer.new(noble, options)}
  end

  def user
    return unless object.user
    UserSerializer.new(object.user, options)
  end

  def isMe
    player_is_me = options[:player] && options[:player].id == object.id
    scope_is_me = options[:scope] && options[:scope].id == object.user.try(:id)
    !!( player_is_me || scope_is_me )
  end
end
