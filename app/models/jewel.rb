class Jewel < ActiveRecord::Base
  belongs_to :user
  belongs_to :game

  def self.generate(game)
    user_count = game.users.count
    jewel_count = case user_count
                  when 2 then 4
                  when 3 then 5
                  when 4 then 7
                  end
    {
      diamond: jewel_count,
      sapphire: jewel_count,
      emerald: jewel_count,
      ruby: jewel_count,
      onyx: jewel_count,
      gold: 5
    }.each do |type, count|
      count.times do
        j = Jewel.new
        j.game = game
        j.jewel_type = type
        j.save
      end
    end
  end
end
