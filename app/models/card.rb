class Card
  #belongs_to :user
  #belongs_to :game

  include ActiveModel::Model
  include ActiveModel::Serialization

  attr_accessor :player,
                :game

  attr_accessor :id,
                :card_grade,
                :jewel_type,
                :point,
                :costs,
                :revealed

  def initialize(game)
    self.game = game
    while id_sample = Forgery('basic').text
      unless self.game.dic[:cards][id_sample]
        self.id = id_sample
        self.game.dic[:cards][id_sample] = self
        break
      end
    end
  end

  def inspect
    "Card"
  end

  def self.generate(game)
    f = File.open("card_sample.csv")
    card_samples = f.read.split("\n").map{|x| x.split(",")}
    card_samples.each do |s|
      c = Card.new(game)
      c.card_grade, diamond, sapphire, emerald, ruby, onyx, c.point, c.jewel_type = s

      c.card_grade = c.card_grade.to_i
      c.point = c.point.to_i
      c.jewel_type = c.jewel_type.to_sym

      c.costs = {
        diamond: diamond.to_i,
        sapphire: sapphire.to_i,
        emerald: emerald.to_i,
        ruby: ruby.to_i,
        onyx: onyx.to_i
      }

      game.center_field.cards[:pack][c.card_grade.to_i] << c
    end

    3.times do |i|
      exhibition_cards = game.center_field.cards[:pack][i+1].shuffle!.shift(4)
      exhibition_cards.each{|card| card.reveal}
      game.center_field.cards[:exhibition][i+1] += exhibition_cards
    end
  end

  def reveal
    self.revealed = true
  end

end
