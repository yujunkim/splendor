$:.push(Rails.root + "vendor" + "splendor-thrift" + "gen-rb")

require 'thrift_client'

require 'player'

$thrift_client = ThriftClient.new(SplendorThrift::Player::Client, '127.0.0.1:9090', retries: 2)
