class GameSerializer < Thriftify
  attributes :id,
             :currentTurnUserId,
             :orderUserIds,
             :winnerId

  def currentTurnUserId
    object.current_turn_user_id
  end

  def orderUserIds
    object.users.map(&:id) rescue []
  end

  def winnerId
    object.winner_id
  end

  has_many :users
  has_many :cards
  has_many :jewelChips
  has_many :nobles
end
