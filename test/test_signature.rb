require 'minitest/autorun'
require_relative '../lib/dbchain_client'

class SignatureTest < Minitest::Test
  def test_sign_and_verify
    mnemonic = "wood word work wood word work wood word work wood word work"
    master_key = DbchainClient::Key.mnemonic_to_master_key(mnemonic)
    key_pair = DbchainClient::Key.master_key_to_cosmos_key_pair(master_key)

    message = "hello"
    signature = DbchainClient::Signature.sign(key_pair[0], message)
    assert_equal true, DbchainClient::Signature.verify(signature, message)
  end
end
