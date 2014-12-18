class Game < ActiveRecord::Base
  has_many :game_user_association
  has_many :users, through: :game_user_association
  belongs_to :current_turn_user, class_name: :User
  belongs_to :winner, class_name: :User
  has_many :cards
  has_many :jewel_chips
  has_many :jewelChips
  has_many :nobles

  # {
  #   user_ids: [],
  #   robot_count: 0
  # }
  def self.generate(options)
    def self.generate_validation(options)
      able = true
      able &&= options[:user_ids] && options[:robot_count]
      able &&= options[:user_ids].count > 0
      participants_count = options[:user_ids].count + options[:robot_count]
      able &&= participants_count >= 2
      able &&= participants_count <= 4
      able
    end

    return unless generate_validation(options)
    users = User.where(id: options[:user_ids]).to_a
    (options[:robot_count] || 0).times do |i|
      users << User.create(robot: true)
    end
    g = Game.create
    g.users = users
    g.order_user_ids = g.users.shuffle.map(&:id).join(",")

    g.current_turn_user_id = g.order_user_ids.split(",").first
    g.save

    Card.generate(g)
    JewelChip.generate(g)
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
    user_ids = order_user_ids.split(",").map(&:to_i)
    idx = user_ids.index(current_turn_user_id)
    idx += 1
    idx = 0 if idx == user_ids.length
    self.current_turn_user_id = user_ids[idx]
    self.save
  end

  def sample_jewel_chips
    groups = jewel_chips.where(user_id: nil).where.not(jewel_type: "gold").group(:jewel_type)
    if groups.count.count > 2
      groups.to_a.sample(3)
    else
      jewel_chips.where(user_id: nil).where.not(jewel_type: "gold").first(2)
    end
  end

  def action(user, options)
    method = options[:actionType].underscore
    return unless ["purchase_card", "reserve_card", "receive_jewel_chip"].include?(method)
    if self.validation(method, user, options)
      action_opts = self.send(method.underscore, user, options)
      self.after_action(user, method, action_opts)
    else
      binding.pry
    end
  end

  def validation(type, user, data)
    def jewel_chip_count(jewel_chip_map)
      return 0 if jewel_chip_map.blank?
      jewel_chip_map.map{|jewel_chip, count| count.to_i}.inject{|sum,x| sum + x }
    end

    able = true
    case type
    when "purchase_card"
      card = Card.find_by_id(data[:cardId])
      able &&= user.purchase_validation(card, data[:returnJewelChipMap])
    when "reserve_card"
      able &&= user.jewel_chips.where(game_id: id).count + jewel_chip_count(data[:receiveJewelChipMap]) <= 10
    when "receive_jewel_chip"
      able &&= (
        user.jewel_chips.where(game_id: id).count +
        jewel_chip_count(data[:receiveJewelChipMap]) -
        jewel_chip_count(data[:returnJewelChipMap]) <= 10
      )
    else
      able = false
    end
    able
  end

  def after_action(user, type, options)
    next_turn
    WebsocketRails["game#{id}"].subscribers.each do |connection|
      connection.send_message :action_performed, type: type,
        d: game_update_data(user, options.merge(scope: connection.user))
    end

    choose_winner if game_over(user)

    if winner
      WebsocketRails["game#{id}"].subscribers.each do |connection|
        connection.send_message :game_over,
          winner: UserSerializer.new(winner, root: false, scope: connection.user)
      end
    else
      Robot.play(id) if self.current_turn_user.robot
    end
  end

  def game_over(user)
    return false if user.id != order_user_ids.split(",").last.to_i
    self.users.map do |u|
      u.total_point(self) > 15
    end.uniq != [false]
  end

  def choose_winner
    point2user = {}
    self.users.each do |u|
      point = u.total_point(self)
      card_count = u.total_cards(self).count
      point2user[point] ||= {}
      point2user[point][card_count] ||= []
      point2user[point][card_count] << u
    end
    card_count2user = point2user.sort.reverse.first.last
    top_users = card_count2user.sort.reverse.first.last
    self.winner = top_users.sample
    self.save

    winner
  end

  #purchased_card: @purchased_card,
  #reserved_card: @reserved_card,
  #revealed_card: @revealed_card,
  #returned_jewel_chips: @returned_jewel_chips,
  #received_jewel_chips: @received_jewel_chips
  def game_update_data(user, options)
    GameUpdateSerializer.new self, options.merge(user: user, root: false)
  end

  def purchase_card(user, data)
    purchased_card = Card.find_by_id(data[:cardId])
    user.purchase(purchased_card)
    hired_noble = user.hire_noble(self)

    revealed_card = purchased_card.game.pickup_unrevealed_card(purchased_card.card_grade)

    returned_jewel_chips = user.return(self, data[:returnJewelChipMap])

    {
      purchased_card: purchased_card,
      revealed_card: revealed_card,
      returned_jewel_chips: returned_jewel_chips,
      hired_noble: hired_noble
    }
  end

  def reserve_card(user, data)
    reserved_card = Card.find_by_id(data[:cardId])
    user.reserve(reserved_card)

    revealed_card = reserved_card.game.pickup_unrevealed_card(reserved_card.card_grade)

    received_jewel_chips = user.receive(self, data[:receiveJewelChipMap])

    {
      reserved_card: reserved_card,
      revealed_card: revealed_card,
      received_jewel_chips: received_jewel_chips
    }
  end

  def receive_jewel_chip(user, data)
    received_jewel_chips = user.receive(self, data[:receiveJewelChipMap])
    returned_jewel_chips = user.return(self, data[:returnJewelChipMap])

    {
      received_jewel_chips: received_jewel_chips,
      returned_jewel_chips: returned_jewel_chips
    }
  end
end
