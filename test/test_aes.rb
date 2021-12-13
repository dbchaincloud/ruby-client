require 'minitest/autorun'
require_relative '../lib/dbchain_client/aes'

class KeyTest < Minitest::Test
  def test_encrpt_decrypt
    plain_text = "this is a plain text without any secret inside"
    password = "plain password as well"

    aes = DbchainClient::AESCrypt.new
    encrypted = aes.encrypt(password, plain_text)
    decrypted = aes.decrypt(password, encrypted)
    assert_equal decrypted, plain_text
  end
end
