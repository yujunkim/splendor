class User < ActiveRecord::Base
  has_many :game_user_associations
  has_many :games, through: :game_user_associations
  has_many :my_turn_games, class_name: :Game, foreign_key: :next_turn_user_id
  has_many :cards
  has_many :jewel_chips
  has_many :nobles

  before_create :fill_auth_token
  before_create :fill_sample_name
  before_create :fill_sample_color
  before_create :fill_default_home

  def fill_auth_token
    self.auth_token = Forgery('basic').encrypt
  end

  def fill_sample_name
    self.name = Forgery('name').full_name
    self.name = "(AI)" + self.name if robot
  end

  def fill_sample_color
    self.color = Forgery('basic').color.underscore
  end

  def fill_default_home
    self.home = "127.0.0.1:9090"
  end

  def purchase(card)
    card.user_id = self.id
    card.reserved = false
    card.save
  end

  def reserve(card)
    card.user_id = self.id
    card.reserved = true
    card.save
  end

  def receive(game, jewel_chip_map)
    return [] if jewel_chip_map.blank?
    result = []
    jewel_chip_map.each do |jewel_type, count|
      game.jewel_chips.where(jewel_type: jewel_type, user_id: nil).first(count).each do |jewel_chip|
        jewel_chip.user_id = self.id
        jewel_chip.save
        result << jewel_chip
      end
    end
    result
  end

  def return(game, jewel_chip_map)
    return [] if jewel_chip_map.blank?
    result = []
    jewel_chip_map.each do |jewel_type, count|
      game.jewel_chips.where(jewel_type: jewel_type, user_id: id).first(count).each do |jewel_chip|
        jewel_chip.user_id = nil
        jewel_chip.save
        result << jewel_chip
      end
    end
    result
  end

  def hire(noble)
    noble.user_id = id
    noble.save
    noble
  end

  def hire_noble(game)
    hired_noble = nil
    game.nobles.where(user_id: nil).each do |noble|
      if hireable?(noble)
        hired_noble = hire(noble)
        break
      end
    end
    hired_noble
  end

  def hireable?(noble)
    having_cards = noble.game.cards.where(user_id: id, reserved: false).group(:jewel_type).count.symbolize_keys
    able = true
    noble.costs.each do |jewel_type, cost|
      able &&= having_cards[jewel_type] && cost <= having_cards[jewel_type]
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
      card_count = Card.where(game_id: card.game.id, user_id: id, jewel_type: jewel_type, reserved: false).count
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
    gold_count = jewel_chip_map[:gold].to_i
    actual_cost(card).each do |jewel_type, cost|
      return unless able
      exist_count = jewel_chip_map[jewel_type].to_i
      if cost > exist_count + gold_count
        able = false
      else
        lack_count = cost - exist_count
        gold_count -= lack_count if lack_count > 0
      end
    end
    able
  end

  def total_point(game)
    total_cards(game).inject(0){|sum, card| sum + card.point} +
    game.nobles.where(user_id: id).inject(0){|sum, noble| sum + noble.point}
  end

  def total_cards(game)
    game.cards.where(user_id: id, reserved: false)
  end

end
