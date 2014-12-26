class CenterFieldSerializer < Thriftify
  attributes :cards,
             :jewelChips,
             :nobles

  def cards
    Hash[object.cards.map do |location_type, location_value|
      location_value_hash = Hash[location_value.map do |grade_type, cards|
        [grade_type, cards.map{|card| CardSerializer.new(card, options)}]
      end]

      [location_type, location_value_hash]
    end]
  end

  def jewelChips
    Hash[object.jewel_chips.map do |jewel_type, jewel_chips|
      [jewel_type, jewel_chips.map{|jewel_chip| JewelChipSerializer.new(jewel_chip, options)}]
    end]
  end

  def nobles
    object.nobles.map{|noble| NobleSerializer.new(noble, options)}
  end
end
