class Robot
  @queue = :robot

  def self.perform(game_id)
    game = Game.find_by_id(game_id)
    return unless game.current_turn_user.robot
    sleep(1)
    robot_user = game.current_turn_user
    type = nil
    options = {}
    game.cards.where(revealed: true, user_id: nil).each do |card|
      if robot_user.purchasable?(card)
        options = game.purchase_card robot_user, card_id: card.id,
          return_jewel_chip_ids: robot_user.return_jewels(card).map(&:id)
        type = "purchase_card"
        break
      end
    end

    unless type
      options = game.receive_jewel robot_user, receive_jewel_chip_ids: game.sample_jewels.map(&:id),
                                return_jewel_chip_ids: []
      type = "receive_jewel"
    end

  ensure
    game.after_action(robot_user, type, options)
  end
end
