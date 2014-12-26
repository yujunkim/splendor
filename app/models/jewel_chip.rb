class JewelChip
  #belongs_to :user
  #belongs_to :game

  include ActiveModel::Model
  include ActiveModel::Serialization

  attr_accessor :player,
                :game

  attr_accessor :id,
                :jewel_type

  def initialize(game)
    self.game = game
    while id_sample = Forgery('basic').text
      unless self.game.dic[:jewel_chips][id_sample]
        self.id = id_sample
        self.game.dic[:jewel_chips][id_sample] = self
        break
      end
    end
  end

  def inspect
    "JewelChip"
  end

  def self.generate(game)
    player_count = game.players.count
    jewel_chip_count = case player_count
                  when 2 then 4
                  when 3 then 5
                  when 4 then 7
                  end
    {
      diamond: jewel_chip_count,
      sapphire: jewel_chip_count,
      emerald: jewel_chip_count,
      ruby: jewel_chip_count,
      onyx: jewel_chip_count,
      gold: 5
    }.each do |type, count|
      count.times do
        j = JewelChip.new(game)
        j.jewel_type = type
        game.center_field.jewel_chips[type] << j
      end
    end
  end
end
