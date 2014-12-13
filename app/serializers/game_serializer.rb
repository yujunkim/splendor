class GameSerializer < ActiveModel::Serializer
  attributes :id,
             :currentTurnUserId

  def currentTurnUserId
    object.current_turn_user_id
  end

  has_many :users
  has_many :cards
  has_many :jewels
  has_many :nobles
end
