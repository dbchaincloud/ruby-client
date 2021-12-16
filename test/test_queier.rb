require 'minitest/autorun'
require_relative '../lib/dbchain_client'

class QuerierTest < Minitest::Test
  def test_querier
    mnemonic = "draft bridge behind upper room media still wool idle spend sunny diamond"
    master_key = DbchainClient::Mnemonics.mnemonic_to_master_key(mnemonic)
    key_pair = DbchainClient::Mnemonics.master_key_to_cosmos_key_pair(master_key)

    q = DbchainClient::Querier.new("http://127.0.0.1/relay", key_pair[0])
    q.set_app_code("EWWR19SIHJ")
#    result = q.table('user').equal('name', 'ethan zhang').find_first.run
#    assert result != nil
#    assert_equal "88", result["age"]
  end
end
