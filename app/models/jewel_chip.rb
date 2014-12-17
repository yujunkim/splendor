class JewelChip < ActiveRecord::Base
  belongs_to :user
  belongs_to :game

  def self.generate(game)
    user_count = game.users.count
    jewel_chip_count = case user_count
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
        j = JewelChip.new
        j.game = game
        j.jewel_type = type
        j.save
      end
    end
  end
end
