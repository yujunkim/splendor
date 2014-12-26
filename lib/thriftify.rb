class Thriftify < ActiveModel::Serializer
  def as_thrift(options = {})
    thrift_object = thrift_class(object.class.name).new
    attributes.each do |k, v|
      v = before_filter(k, v, options)
      thrift_object.send("#{k}=", v) rescue nil
    end

    _associations.each do |k, _|
      thrift_association_objects = object.send(k).map do |model|
        serializer_object = serializer_class(model.class.name).new(model, @options)
        serializer_object.as_thrift(options)
      end
      thrift_object.send("#{k}=", thrift_association_objects) rescue nil
    end

    thrift_object
  end

  def before_filter(k, v, options)
    return unless v
    case k
    when :jewelType
      jewel_type_thriftify(v)
    when :costs
      Hash[v.map do |jewel_type, cost|
        ["SplendorThrift::JewelType::#{jewel_type.upcase}".safe_constantize, cost]
      end]
    when :centerField
      v.as_thrift(options)
    when :players
      v.map{|player| player.as_thrift}
    when :cards
      Hash[v.map do |location_type, location_value|
        location_value_hash = Hash[location_value.map do |grade_type, cards|
          [grade_type, cards.map{|card| card.as_thrift(options)}]
        end]

        location_type = "SplendorThrift::CardLocation::#{location_type.upcase}".safe_constantize
        [location_type, location_value_hash]
      end]
    when :nobles
      v.map{|noble| noble.as_thrift(options)}
    when :jewelChips
      Hash[v.map do |jewel_type, jewel_chips|
        [jewel_type_thriftify(jewel_type), jewel_chips.map{|jewel_chip| jewel_chip.as_thrift(options)}]
      end]
    when :purchasedCards
      Hash[v.map do |jewel_type, cards|
        [jewel_type_thriftify(jewel_type), cards.map{|card| card.as_thrift(options)}]
      end]
    when :reservedCards
      v.map{|card| card.as_thrift(options)}
    else
      v
    end
  end

  def jewel_type_thriftify(jewel_type)
    "SplendorThrift::JewelType::#{jewel_type.upcase}".safe_constantize
  end

  def thrift_class(class_name)
    "SplendorThrift::#{class_name}".safe_constantize
  end

  def serializer_class(class_name)
    "#{class_name}Serializer".safe_constantize
  end

end
