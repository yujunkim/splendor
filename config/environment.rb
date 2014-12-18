# Load the Rails application.
require File.expand_path('../application', __FILE__)

DIAMOND = 0
SAPPHIRE = 1
EMERALD = 2
RUBY = 3
ONYX = 4
GOLD = 5

JewelType = {
  DIAMOND => "diamond",
  SAPPHIRE => "sapphire",
  EMERALD => "emerald",
  RUBY => "ruby",
  ONYX => "onyx",
  GOLD => "gold"
}

PURCHASE_CARD = 0
RESERVE_CARD = 1
RECEIVE_JEWEL_CHIP = 2

ActionType = {
  PURCHASE_CARD => "purchase_card",
  RESERVE_CARD => "reserve_card",
  RECEIVE_JEWEL_CHIP => "receive_jewel_chip"
}
# Initialize the Rails application.
Rails.application.initialize!
