require 'singleton'
require 'securerandom'
require 'digest'

module DbchainClient
  class KeyEscrow 
    include Singleton

    SUFFIX_SECRET = "secret"
    SUFFIX_PRIVATE = "private"

    def create_and_save_private_key_with_password(username, password, key_store_obj)
      private_key = DbchainClient::Mnemonics.generate_private_key
      save_private_key(username, password, private_key, key_store_obj) 
    end 
  
    def load_private_key_with_password(username, password, key_store_obj)
      load_private_key(username, password, key_store_obj)
    end
  
    def save_private_key_with_recovery_phrase(username, recovery_phrase, private_key, key_store_obj)
      save_private_key(username, recovery_phrase, private_key, key_store_obj)
    end
  
    def load_private_key_by_recovery_phrase(username, recovery_phrase, key_store_obj)
      load_private_key(username, recovery_phrase, key_store_obj) 
    end
  
    def reset_password_from_recovery_phrase(username, recovery_phrase, new_password, key_store_obj)
      private_key = load_private_key(username, recovery_phrase, key_store_obj) or raise "Failed to retrieve private key"
      save_private_key(username, new_password, private_key, key_store_obj)
    end
  
    def reset_password_from_old(username, old_password, new_password, key_store_obj)
      private_key = load_private_key(username, old_password, key_store_obj) or raise "Failed to retrive private key"
      save_private_key(username, new_password, private_key, key_store_obj)
    end
  
    private
  
    def save_private_key(username, password_or_recovery_phrase, private_key, key_store_obj)
      seed = random_seed()
      aes = DbchainClient::AESCrypt.new
      encrypted_private_key = aes.encrypt(f1(seed, password_or_recovery_phrase), private_key)
      secret = aes.encrypt(f2(username, password_or_recovery_phrase), seed)
      key_of_secret = hash1(username, password_or_recovery_phrase)
      key_of_private = hash2(username, password_or_recovery_phrase)
      key_store_obj.save(key_of_private, encrypted_private_key) && key_store_obj.save(key_of_secret, secret)
    end
  
    def load_private_key(username, password_or_recovery_phrase, key_store_obj)
      key_of_secret = hash1(username, password_or_recovery_phrase)
      key_of_private = hash2(username, password_or_recovery_phrase)
      secret = key_store_obj.load(key_of_secret)
      encrypted_private_key = key_store_obj.load(key_of_private)

      aes = DbchainClient::AESCrypt.new
      seed = aes.decrypt(f2(username, password_or_recovery_phrase), secret)
      aes.decrypt(f1(seed, password_or_recovery_phrase), encrypted_private_key)
    end
  
    def f1(str1, str2)
      Digest::SHA256.digest(str1 + str2)
    end
  
    def f2(str1, str2)
      f1(str1, str2)
    end
  
    def hash1(str1, str2)
      Digest::SHA256.digest(str1 + str2 + SUFFIX_SECRET)
    end
  
    def hash2(str1, str2)
      Digest::SHA256.digest(str1 + str2 + SUFFIX_PRIVATE)
    end
  
    def random_seed()
      SecureRandom.random_bytes(32)
    end
  end
  
  # This key store is for test purpose. Developers are supposed to implement their own key store for production.
  class KeyStore
    def initialize
      @h = {}
    end
  
    def save(key, value)
      @h[key] = value
    end
  
    def load(key)
      @h[key]
    end
  end
end
