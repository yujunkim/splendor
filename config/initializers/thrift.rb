$:.push(Rails.root + "vendor" + "splendor-thrift" + "gen-rb")

require 'thrift'
require 'thrift_client'

require 'player'

$thrift_client = ThriftClient.new(SplendorThrift::Player::Client, 'thrift.splendor.yujun.kim:80', retries: 2)
