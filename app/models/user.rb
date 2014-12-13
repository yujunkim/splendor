class User < ActiveRecord::Base
  has_many :game_user_association
  has_many :games, through: :game_user_association
  has_many :my_turn_games, class_name: :Game, foreign_key: :next_turn_user_id
  has_many :cards
  has_many :jewels
  has_many :nobles

  before_create :fill_auth_token
  before_create :fill_sample_name
  before_create :fill_sample_color

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

  def purchase(card)
    card.user_id = self.id
    card.save
  end

  def reserve(card)
    card.user_id = self.id
    card.reserved = self.id
    card.save
  end

  def receive(jewel)
    jewel.user_id = self.id
    jewel.save
  end

  def return(jewel)
    jewel.user_id = nil
    jewel.save
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
      jewel_count = Jewel.where(game_id: card.game.id, user_id: id, jewel_type: jewel_type).count
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

  def return_jewels(card)
    jewels = []
    actual_cost(card).each do |jewel_type, cost|
      next if cost <= 0
      jewels += Jewel.where(game_id: card.game.id, user_id: id, jewel_type: jewel_type).first(cost)
    end
    jewels
  end
end
