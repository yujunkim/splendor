class UserSerializer < ActiveModel::Serializer
  attributes :id,
             :name,
             :color,
             :me

  def me
    options[:scope] && options[:scope].id == id
  end
end
