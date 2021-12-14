require 'minitest/autorun'
require_relative '../lib/dbchain_client'

class TransactionTest < Minitest::Test
  def test_send_transaction
#    mnemonic = "wood word work wood word work wood word work wood word work"
    mnemonic = "draft bridge behind upper room media still wool idle spend sunny diamond"
    master_key = DbchainClient::Mnemonics.mnemonic_to_master_key(mnemonic)
    key_pair = DbchainClient::Mnemonics.master_key_to_cosmos_key_pair(master_key)

#    writer = DbchainClient::Writer.new("http://127.0.0.1/relay", "testnet", key_pair[0])
#    writer.insert_row("EWWR19SIHJ", "user", {name: "bar", age: "23"})
  end
end
