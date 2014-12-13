class Game < ActiveRecord::Base
  has_many :game_user_association
  has_many :users, through: :game_user_association
  belongs_to :current_turn_user, class_name: :User
  has_many :cards
  has_many :jewels
  has_many :nobles

  def self.generate(users)
    g = Game.create
    g.users = users

    g.current_turn_user = g.users.first
    g.save

    Card.generate(g)
    Jewel.generate(g)
    Noble.generate(g)
    g
  end

  def pickup_unrevealed_card(grade)
    return if self.cards.where(revealed: true, card_grade: grade, user_id: nil).count >= 4
    card = self.cards.where(revealed: false, card_grade: grade, user_id: nil).sample
    return unless card
    card.revealed = true
    card.save
    card
  end

  def next_turn
    user_ids = users.map(&:id)
    idx = user_ids.index(current_turn_user_id)
    idx += 1
    idx = 0 if idx == user_ids.length
    self.current_turn_user_id = user_ids[idx]
    self.save
  end

  def sample_jewels
    groups = jewels.where(user_id: nil).where.not(jewel_type: "gold").group(:jewel_type)
    if groups.count.count > 2
      groups.to_a.sample(3)
    else
      jewels.where(user_id: nil).where.not(jewel_type: "gold").first(2)
    end
  end

  def after_action(user, type, options)
    next_turn
    WebsocketRails[:aaa_channel].subscribers.each do |connection|
      connection.send_message :action_performed, type: type,
        d: game_update_data(connection.user, options)
    end
    Resque.enqueue(Robot, self.id) if self.current_turn_user.robot
  end

  #purchased_card: @purchased_card,
  #reserved_card: @reserved_card,
  #revealed_card: @revealed_card,
  #returned_jewel_chips: @returned_jewel_chips,
  #received_jewel_chips: @received_jewel_chips
  def game_update_data(user, options)
    GameUpdateSerializer.new self, options.merge(root: false, scope: user)
  end

  def purchase_card(user, data)
    purchased_card = Card.find_by_id(data[:card_id])
    user.purchase(purchased_card)
    hired_noble = user.hire_noble(self)

    revealed_card = purchased_card.game.pickup_unrevealed_card(purchased_card.card_grade)

    returned_jewel_chips = Jewel.where(id: data[:return_jewel_chip_ids])
    returned_jewel_chips.each { |jewel| user.return(jewel) }

    {
      purchased_card: purchased_card,
      revealed_card: revealed_card,
      returned_jewel_chips: returned_jewel_chips,
      hired_noble: hired_noble
    }
  end

  def reserve_card(user, data)
    reserved_card = Card.find_by_id(data[:card_id])
    user.reserve(reserved_card)

    revealed_card = reserved_card.game.pickup_unrevealed_card(reserved_card.card_grade)

    received_jewel_chips = Jewel.where(id: data[:receive_jewel_chip_ids])
    received_jewel_chips.each { |jewel| user.receive(jewel) }

    {
      reserved_card: reserved_card,
      revealed_card: revealed_card,
      received_jewel_chips: received_jewel_chips
    }
  end

  def receive_jewel(user, data)
    received_jewel_chips = Jewel.where(id: data[:receive_jewel_chip_ids])
    received_jewel_chips.each { |jewel| user.receive(jewel) }

    returned_jewel_chips = Jewel.where(id: data[:return_jewel_chip_ids])
    returned_jewel_chips.each { |jewel| user.return(jewel) }

    {
      received_jewel_chips: received_jewel_chips,
      returned_jewel_chips: returned_jewel_chips
    }
  end
end
