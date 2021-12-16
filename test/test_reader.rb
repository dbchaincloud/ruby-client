require 'minitest/autorun'
require_relative '../lib/dbchain_client'

class ReaderTest < Minitest::Test
  def test_access_code
    mnemonic = "wood word work wood word work wood word work wood word work"
    master_key = DbchainClient::Mnemonics.mnemonic_to_master_key(mnemonic)
    key_pair = DbchainClient::Mnemonics.master_key_to_cosmos_key_pair(master_key)

    text = "1639593186922"
    private_key = DbchainClient::PrivateKey.new(key_pair[0])
    reader = DbchainClient::Reader.new(nil, private_key)
    access_code = reader.generate_access_code(text)

    assert_equal access_code, "qFPJuD5At5Gq13JGx74UUSDCxVwG9XkVXjvhnUWoquv8:1639593186922:nbGmtFATrC44tzWxVnia7zBXDcXviy8CzZwWCEShU6gDtTxNUpsDoa3XjA5UQc38rFL4zC2N1fG8A5Ea2W71Zsn"
  end

  def test_get_row
    mnemonic = "draft bridge behind upper room media still wool idle spend sunny diamond"
    master_key = DbchainClient::Mnemonics.mnemonic_to_master_key(mnemonic)
    key_pair = DbchainClient::Mnemonics.master_key_to_cosmos_key_pair(master_key)

    reader = DbchainClient::Reader.new("http://127.0.0.1/relay", key_pair[0])
    result = reader.get_row("EWWR19SIHJ", "user", 1)
    assert_equal "ethan zhang", result["name"]
  end
end
