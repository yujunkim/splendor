$:.push(Rails.root + "vendor" + "splendor-thrift" + "gen-rb")

require 'thrift'
require 'thrift_client'

require 'player'

$thrift_client = ThriftClient.new(SplendorThrift::Player::Client, '127.0.0.1:9090', retries: 2)

if Rails.const_defined? "Server"
  # do NOT use db access or others without thrift data
  fork do
    $:.push(Rails.root + "vendor" + "splendor-thrift")
    require 'server'
    thrift_server_start
  end
end
