require 'minitest/autorun'
require_relative '../lib/dbchain_client'

class SignatureTest < Minitest::Test
  def test_sign_and_verify
    mnemonic = "wood word work wood word work wood word work wood word work"
    master_key = DbchainClient::Mnemonics.mnemonic_to_master_key(mnemonic)
    key_pair = DbchainClient::Mnemonics.master_key_to_cosmos_key_pair(master_key)

    message = "hello"
    private_key = DbchainClient::PrivateKey.new(key_pair[0])
    signature = private_key.sign(message)
    assert private_key.public_key.verify(message, signature)
  end
end
