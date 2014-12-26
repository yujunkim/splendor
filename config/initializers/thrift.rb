$:.push(Rails.root + "vendor" + "splendor-thrift" + "gen-rb")

require 'thrift'
require 'thrift_client'

require 'splendor_ai'

$thrift_client = ThriftClient.new(SplendorThrift::SplendorAi::Client, 'thrift.splendor.yujun.kim:80', retries: 2)
