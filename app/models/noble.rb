class Noble
  #belongs_to :user
  #belongs_to :game

  include ActiveModel::Model
  include ActiveModel::Serialization

  attr_accessor :player,
                :game

  attr_accessor :id,
                :point,
                :costs

  def initialize(game)
    self.game = game
    while id_sample = Forgery('basic').text
      unless self.game.dic[:nobles][id_sample]
        self.id = id_sample
        self.game.dic[:nobles][id_sample] = self
        break
      end
    end
  end

  def inspect
    "Noble"
  end

  def self.generate(game)
    player_count = game.players.count
    f = File.open("noble_sample.csv")
    noble_samples = f.read.split("\n").map{|x| x.split(",")}
    noble_samples.shuffle.first(player_count + 1).each do |s|
      n = Noble.new(game)
      diamond, sapphire, emerald, ruby, onyx, n.point = s
      n.point = n.point.to_i

      n.costs = {
        diamond: diamond.to_i,
        sapphire: sapphire.to_i,
        emerald: emerald.to_i,
        ruby: ruby.to_i,
        onyx: onyx.to_i
      }

      game.center_field.nobles << n
    end
  end

end
