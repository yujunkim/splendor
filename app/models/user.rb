class User
  #has_many :game_user_associations
  #has_many :games, through: :game_user_associations
  #has_many :my_turn_games, class_name: :Game, foreign_key: :next_turn_user_id
  #has_many :cards
  #has_many :jewel_chips
  #has_many :nobles
  #scope :human, -> { where(robot: false) }
  #scope :robot, -> { where(robot: true) }

  #before_create :fill_auth_token
  #before_create :fill_sample_name
  #before_create :fill_sample_color
  #before_destroy :destroy_related_games

  include ActiveModel::Model
  include ActiveModel::Serialization

  attr_accessor :id,
                :fid,
                :email,
                :name,
                :photo_url,
                :is_robot,
                :home

  attr_accessor :players

  alias_method :isRobot, :is_robot

  def self.all
    Splendor::Application::Record[:user]
  end

  def initialize
    self.id = Forgery('basic').encrypt
    self.players = []
    Splendor::Application::Record[:user][id] = self
  end

  def self.find_by_id(id)
    Splendor::Application::Record[:user][id]
  end

  def add_facebook_user(facebook_user)
    self.fid = facebook_user[:id]
    self.email = facebook_user[:email]
    self.name = facebook_user[:name]
    self.photo_url = "http://graph.facebook.com/#{fid}/picture?type=square"
  end
end
