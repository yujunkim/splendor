class Thriftify < ActiveModel::Serializer
  def as_thrift(options = {})
    thrift_object = thrift_class(object.class.name).new
    attributes.each do |k, v|
      v = before_filter(k, v)
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

  def before_filter(k, v)
    case k
    when :jewelType
      return unless v
      "SplendorThrift::JewelType::#{v.upcase}".safe_constantize
    when :costs
      return unless v
      Hash[v.map do |jewel_type, cost|
        ["SplendorThrift::JewelType::#{jewel_type.upcase}".safe_constantize, cost]
      end]
    else
      v
    end
  end

  def thrift_class(class_name)
    "SplendorThrift::#{class_name}".safe_constantize
  end

  def serializer_class(class_name)
    "#{class_name}Serializer".safe_constantize
  end

end
