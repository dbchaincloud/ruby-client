require 'minitest/autorun'
require_relative '../lib/dbchain_client/key_escrow'

class KeyTest < Minitest::Test
  def test_key_escrow_features
    key_store_obj = DbchainClient::KeyStore.new
    escrow = DbchainClient::KeyEscrow.instance
    username1 = "foo@gmail.com"
    password1 = "plain password"

    username2 = "18802345678"
    password2 = "another plain password"

    escrow.create_and_save_private_key_with_password(username1, password1, key_store_obj)
    escrow.create_and_save_private_key_with_password(username2, password2, key_store_obj)
    pk1 = escrow.load_private_key_with_password(username1, password1, key_store_obj)
    pk2 = escrow.load_private_key_with_password(username2, password2, key_store_obj)

    pk1_again = escrow.load_private_key_with_password(username1, password1, key_store_obj)
    pk2_again = escrow.load_private_key_with_password(username2, password2, key_store_obj)

    assert_equal pk1, pk1_again
    assert_equal pk2, pk2_again

    recovery_phrase = "i'm the secret weapon to recover private key"
    escrow.save_private_key_with_recovery_phrase(username1, recovery_phrase, pk1, key_store_obj)
    pk3 = escrow.load_private_key_by_recovery_phrase(username1, recovery_phrase, key_store_obj)

    assert_equal pk1, pk3

    new_password = "Sorry I don't rememver the old password"
    escrow.reset_password_from_recovery_phrase(username1, recovery_phrase, new_password, key_store_obj)
    pk4 = escrow.load_private_key_with_password(username1, new_password, key_store_obj)
    assert_equal pk1, pk4

    newer_password = "I'm tired of changing password"
    escrow.reset_password_from_old(username1, new_password, newer_password, key_store_obj)
    pk5 = escrow.load_private_key_with_password(username1, newer_password, key_store_obj)
    assert_equal pk1, pk5
  end
end
