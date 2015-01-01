class Game
  #has_many :game_user_associations, dependent: :destroy
  #has_many :users, -> { order('game_user_associations.order ASC') }, through: :game_user_associations
  #belongs_to :current_turn_user, class_name: :User
  #belongs_to :winner, class_name: :User
  #has_many :cards, dependent: :destroy
  #has_many :jewel_chips, dependent: :destroy
  #has_many :jewelChips, dependent: :destroy
  #has_many :nobles, dependent: :destroy

  include ActiveModel::Model
  include ActiveModel::Serialization

  attr_accessor :players,
                :winner,
                :center_field,
                :dic

  attr_accessor :id

  attr_accessor :host_with_port,
                :runner_count,
                :action_count

  alias_method :centerField, :center_field

  def self.all
    Splendor::Application::Record[:game]
  end

  def self.find_by_id(id)
    Splendor::Application::Record[:game][id]
  end

  def initialize(options)
    def self.generate_validation(options)
      able = true
      able &&= options[:user_ids] && options[:robot_count]
      participants_count = options[:user_ids].count + options[:robot_count]
      able &&= participants_count >= 2
      able &&= participants_count <= 4
      able
    end

    return unless generate_validation(options)

    self.id = Forgery('basic').text
    self.runner_count = 0
    self.action_count = 0
    Splendor::Application::Record[:game][id] = self

    options[:robot_count] ||= 0
    options[:user_ids] ||= []

    self.players ||= []
    self.dic = {
      cards: {},
      jewel_chips: {},
      nobles: {}
    }

    chief_choosed = false
    options[:user_ids].each do |user_id|
      user = User.find_by_id(user_id)
      if user
        player = Player.new(game: self, user: user)
        unless chief_choosed
          player.is_chief = true
          chief_choosed = true
        end
        self.players << player
      end
    end

    (options[:robot_count] || 0).times do |i|
      robot_player = Player.new(game: self, is_robot: true)
      self.players << robot_player
    end
    self.players.shuffle!

    self.center_field = CenterField.new(game: self)

    Card.generate(self)
    JewelChip.generate(self)
    Noble.generate(self)
  end

  def turn_count
    1 + ((action_count - 1) / players.count)
  end

  alias_method :turnCount, :turn_count

  def run
    self.runner_count -= 1
    self.runner_count = 0 if self.runner_count < 0

    if self.runner_count == 0
      self.runner_count += 1
      Robot.play(self)
    end
  end

  def next_turn
    players << players.shift
    self.action_count += 1
  end

  def action(player, options)
    def options_transform(data)
      if data[:receiveJewelChipMap]
        data[:receiveJewelChipMap] = Hash[data[:receiveJewelChipMap].map do |key, value|
          [key.to_sym, value.to_i]
        end]
      end
      if data[:returnJewelChipMap]
        data[:returnJewelChipMap] = Hash[data[:returnJewelChipMap].map do |key, value|
          [key.to_sym, value.to_i]
        end]
      end
      data
    end
    data = options_transform((options[:d] || {}))
    method = options[:method].underscore

    return unless ["purchase_card", "reserve_card", "receive_jewel_chip"].include?(method)
    if self.validation(method, player, data)
      puts "validation passed"
      action_opts = self.send(method, player, data)
      puts "sended"
      self.after_action(player, method, action_opts)
    else
      Rails.logger.info(player)
      Rails.logger.info(options)
    end

  end

  def validation(type, player, data)
    def jewel_chip_types(jewel_chip_map)
      return [] if jewel_chip_map.blank?
      jewel_chip_map.map{|jewel_chip, count| Array.new(count.to_i, jewel_chip.to_sym)}.flatten
    end

    able = true
    able &&= self.players.first == player
    case type
    when "purchase_card"
      card = dic[:cards][data[:cardId]]
      able &&= player.purchase_validation(card, data[:returnJewelChipMap])
    when "reserve_card"
      able &&= (
        player.jewel_chips.values.flatten.count +
        jewel_chip_types(data[:receiveJewelChipMap]).count -
        jewel_chip_types(data[:returnJewelChipMap]).count <= 10
      )

      able &&= player.reserved_cards.count <= 2
    when "receive_jewel_chip"
      able &&= (
        player.jewel_chips.values.flatten.count +
        jewel_chip_types(data[:receiveJewelChipMap]).count -
        jewel_chip_types(data[:returnJewelChipMap]).count <= 10
      )

      receive_jewel_chip_types = jewel_chip_types(data[:receiveJewelChipMap])
      if able && receive_jewel_chip_types.count == 2 && receive_jewel_chip_types.uniq.count == 1
        able &&= self.center_field.jewel_chips[receive_jewel_chip_types.first].count >= 4
      end
    else
      able = false
    end
    able
  end

  def after_action(player, type, options)
    next_turn
    WebsocketRails["game#{id}"].subscribers.each do |connection|
      connection.send_message :action_performed, type: type,
        d: game_update_data(player, options.merge(scope: connection.user))
    end

    choose_winner if game_over(player)

    if winner
      WebsocketRails["game#{id}"].subscribers.each do |connection|
        connection.send_message :game_over,
          winnerId: winner.id
      end
    else
      run if self.players.first.is_robot
    end
  end

  def game_over(player)
    return false unless action_count % players.count == 0
    self.players.map do |p|
      p.total_point >= 15
    end.uniq != [false]
  end

  def choose_winner
    point2player = {}
    self.players.each do |p|
      point = p.total_point
      card_count = p.total_cards.count
      point2player[point] ||= {}
      point2player[point][card_count] ||= []
      point2player[point][card_count] << p
    end
    card_count2player = point2player.sort.reverse.first.last
    top_players = card_count2player.sort.reverse.first.last
    self.winner = top_players.sample

    winner.has_win = true

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

  def purchase_card(player, data)
    purchased_card = dic[:cards][data[:cardId]]
    center_field.remove(purchased_card)
    player.purchase(purchased_card)

    if hired_noble = player.hireable_nobles(self).first
      center_field.remove(hired_noble)
      player.hire(hired_noble)
    end

    revealed_card = center_field.pickup_unrevealed_card(purchased_card.card_grade)

    returned_jewel_chips = player.return(self, data[:returnJewelChipMap])

    {
      purchased_card: purchased_card,
      revealed_card: revealed_card,
      returned_jewel_chips: returned_jewel_chips,
      hired_noble: hired_noble
    }
  end

  def reserve_card(player, data)
    reserved_card = dic[:cards][data[:cardId]]
    center_field.remove(reserved_card)
    player.reserve(reserved_card)

    revealed_card = center_field.pickup_unrevealed_card(reserved_card.card_grade)

    received_jewel_chips = player.receive(self, data[:receiveJewelChipMap])
    returned_jewel_chips = player.return(self, data[:returnJewelChipMap])

    {
      reserved_card: reserved_card,
      revealed_card: revealed_card,
      received_jewel_chips: received_jewel_chips,
      returned_jewel_chips: returned_jewel_chips
    }
  end

  def receive_jewel_chip(player, data)
    received_jewel_chips = player.receive(self, data[:receiveJewelChipMap])
    returned_jewel_chips = player.return(self, data[:returnJewelChipMap])

    {
      received_jewel_chips: received_jewel_chips,
      returned_jewel_chips: returned_jewel_chips
    }
  end


  def winner_name
    return "Not End" unless winner

    if winner.user
      winner.user.name
    else
      "Robot"
    end
  end
end
