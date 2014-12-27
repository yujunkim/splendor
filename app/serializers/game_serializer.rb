class GameSerializer < Thriftify
  attributes :id,
             :winner,
             :players,
             :centerField,
             :turnCount

  def players
    object.players.map do |player|
      PlayerSerializer.new(player, options)
    end
  end

  def centerField
    CenterFieldSerializer.new(object.center_field, options)
  end
end
