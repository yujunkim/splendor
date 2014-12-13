class Noble < ActiveRecord::Base
  belongs_to :user
  belongs_to :game

  def self.generate(game)
    user_count = game.users.count
    f = File.open("noble_sample.csv")
    noble_samples = f.read.split("\n").map{|x| x.split(",")}
    noble_samples.shuffle.first(user_count + 1).each do |s|
      n = Noble.new
      n.game = game
      n.diamond, n.sapphire, n.emerald, n.ruby, n.onyx, n.point = s
      n.save
    end
  end

  def costs
    self.attributes.symbolize_keys.slice(:diamond, :sapphire, :emerald, :ruby, :onyx)
  end
end
