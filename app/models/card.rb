class Card < ActiveRecord::Base
  belongs_to :user
  belongs_to :game

  def self.generate(game)
    f = File.open("card_sample.csv")
    card_samples = f.read.split("\n").map{|x| x.split(",")}
    card_samples.each do |s|
      c = Card.new
      c.game = game
      c.card_grade, c.diamond, c.sapphire, c.emerald, c.ruby, c.onyx, c.point, c.jewel_type = s
      c.save
    end
    3.times do |i|
      game.cards.where(card_grade: i+1).sample(4).each do |c|
        c.revealed = true
        c.save
      end
    end
  end

  def costs
    self.attributes.symbolize_keys.slice(:diamond, :sapphire, :emerald, :ruby, :onyx)
  end

end
