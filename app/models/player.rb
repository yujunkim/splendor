class Player
  #has_many :game_user_associations
  #has_many :games, through: :game_user_associations
  #has_many :my_turn_games, class_name: :Game, foreign_key: :next_turn_user_id
  #has_many :cards
  #has_many :jewel_chips
  #has_many :nobles
  #scope :human, -> { where(robot: false) }
  #scope :robot, -> { where(robot: true) }

  #before_create :fill_auth_token
  #before_create :fill_sample_name
  #before_create :fill_sample_color
  #before_destroy :destroy_related_games

  include ActiveModel::Model
  include ActiveModel::Serialization

  attr_accessor :user,
                :game

  attr_accessor :purchased_cards,
                :reserved_cards,
                :jewel_chips,
                :nobles

  attr_accessor :id,
                :color,
                :is_robot,
                :is_chief,
                :home

  alias_method :isRobot, :is_robot
  alias_method :isChief, :is_chief

  def initialize(options)
    self.id = Forgery('basic').text
    self.color = Forgery('basic').color.underscore
    self.game = options[:game]
    self.user = options[:user]
    self.is_robot = !!options[:is_robot]
    if user
      user.players << self
      self.is_robot = user.is_robot
      self.home = user.home
    end

    self.purchased_cards = {
      diamond: [],
      sapphire: [],
      emerald: [],
      ruby: [],
      onyx: [],
      gold: []
    }
    self.reserved_cards = []
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

  def inspect
    "Player, is_robot: #{is_robot}"
  end

  def purchase(card)
    self.purchased_cards[card.jewel_type] << card
  end

  def reserve(card)
    reserved_card << card
  end

  def receive(game, jewel_chip_map)
    return [] if jewel_chip_map.blank?
    jewel_chip_map = jewel_chip_map.symbolize_keys

    result = []
    jewel_chip_map.each do |jewel_type, count|
      game.center_field.jewel_chips[jewel_type].first(count).each do |jewel_chip|
        game.center_field.jewel_chips[jewel_type].delete(jewel_chip)
        jewel_chips[jewel_type] << jewel_chip
        result << jewel_chip
      end
    end
    result
  end

  def return(game, jewel_chip_map)
    return [] if jewel_chip_map.blank?
    jewel_chip_map = jewel_chip_map.symbolize_keys

    result = []
    jewel_chip_map.each do |jewel_type, count|
      jewel_chips[jewel_type].first(count).each do |jewel_chip|
        game.center_field.jewel_chips[jewel_type] << jewel_chip
        jewel_chips[jewel_type].delete(jewel_chip)
        result << jewel_chip
      end
    end
    result
  end

  def hire(noble)
    self.nobles << noble
  end

  def hireable_nobles(game)
    game.center_field.nobles.select do |noble|
      hireable?(noble)
    end
  end

  def hireable?(noble)
    able = true
    noble.costs.each do |jewel_type, cost|
      able &&= cost <= purchased_cards[jewel_type].count
    end
    able
  end

  def purchasable?(card)
    card.costs.map do |jewel_type, cost|
      card_count = Card.where(game_id: card.game.id, user_id: id, jewel_type: jewel_type, reserved: false).count
      jewel_count = JewelChip.where(game_id: card.game.id, user_id: id, jewel_type: jewel_type).count
      card_count + jewel_count >= cost
    end.uniq == [true]
  end

  def actual_cost(card)
    costs = {}
    card.costs.each do |jewel_type, cost|
      card_count = self.purchased_cards[jewel_type].count
      costs[jewel_type] = cost - card_count
    end
    costs
  end

  def return_jewel_chips(card)
    jewel_chips = []
    actual_cost(card).each do |jewel_type, cost|
      next if cost <= 0
      jewel_chips += JewelChip.where(game_id: card.game.id, user_id: id, jewel_type: jewel_type).first(cost)
    end
    jewel_chips
  end

  def purchase_validation(card, jewel_chip_map)
    able = true
    jewel_chip_map = jewel_chip_map.symbolize_keys

    jewel_chip_map.each do |jewel_type, count|
      able &&= self.jewel_chips[jewel_type].count >= count
    end

    gold_count = jewel_chip_map[:gold].to_i
    actual_cost(card).each do |jewel_type, cost|
      return unless able
      exist_count = jewel_chip_map[jewel_type]
      if cost > exist_count + gold_count
        able = false
      else
        lack_count = cost - exist_count
        gold_count -= lack_count if lack_count > 0
      end
    end
    able
  end

  def total_point
    purchased_cards.values.flatten.inject(0){|sum, card| sum + card.point} +
      nobles.inject(0){|sum, noble| sum + noble.point}
  end

  def total_cards
    purchased_cards.values.flatten
  end

end
