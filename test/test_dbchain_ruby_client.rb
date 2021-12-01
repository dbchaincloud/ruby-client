require 'minitest/autorun'
require_relative '../lib/dbchain_client'

class DbchainRubyClientTest < Minitest::Test
  def test_generate_master
    mnemonic = "wood word work wood word work wood word work wood word work"
    master_key = DbchainRubyClient::Key.mnemonic_to_master_key(mnemonic)
    assert_equal master_key.chain_code.bth,
      "26fd0ed9faeb9837d88f211dccd337605f5785b75e83a167b862973d2f3e36da"

    assert_equal master_key.priv,
      "f719e7aa6d990f5f101ddbe6a1a60a71111e80efa60b93368bbb3a4b0fde7e43"
  end

  def test_address_generation
    mnemonic = "wood word work wood word work wood word work wood word work"
    master_key = DbchainRubyClient::Key.mnemonic_to_master_key(mnemonic)
    key_pair = DbchainRubyClient::Key.master_key_to_cosmos_key_pair(master_key)

    assert_equal DbchainRubyClient::Key.public_key_to_address(key_pair[1]),
      "cosmos1vtajdmhsg965txkp2jv4txfngqpfc4lgyzrg4n"

  end
end
