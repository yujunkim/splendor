class CenterField
  include ActiveModel::Model
  include ActiveModel::Serialization

  attr_accessor :game,
                :cards,
                :jewel_chips,
                :nobles

  def initialize(options)
    self.game = options[:game]
    self.cards = {
      pack: {
        1 => [],
        2 => [],
        3 => []
      },
      exhibition: {
        1 => [],
        2 => [],
        3 => []
      }
    }
    self.nobles = []

    self.jewel_chips = {
      diamond: [],
      sapphire: [],
      emerald: [],
      ruby: [],
      onyx: [],
      gold: []
    }
  end

  def remove(instance)
    case instance.class.name
    when "Card"
      cards[:pack][instance.card_grade].delete(instance)
      cards[:exhibition][instance.card_grade].delete(instance)
    when "Noble"
      nobles.delete(instance)
    when "JewelChip"
      jewel_chips[instance.jewel_type].delete(instance)
    end
  end

  def add(instance)
    case instance.class
    when "JewelChip"
      jewel_chips[instance.jewel_type] << instance
    end
  end

  def pickup_unrevealed_card(grade)
    card = cards[:pack][grade].sample
    return unless cards[:exhibition][grade].count <= 3 && card
    cards[:pack][grade].delete(card)
    cards[:exhibition][grade] << card
    card.reveal
    card
  end

end
