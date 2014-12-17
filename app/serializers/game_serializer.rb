class GameSerializer < Thriftify
  attributes :id,
             :currentTurnUserId,
             :orderUserIds,
             :winnerId

  def currentTurnUserId
    object.current_turn_user_id
  end

  def orderUserIds
    object.order_user_ids.split(",").map(&:to_i) rescue []
  end

  def winnerId
    object.winner_id
  end

  has_many :users
  has_many :cards
  has_many :jewelChips
  has_many :nobles
end
