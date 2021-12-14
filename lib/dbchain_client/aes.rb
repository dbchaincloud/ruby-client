require 'base64'
require 'digest'
require 'openssl'

module DbchainClient 
  class AESCrypt
    def initialize
      @cipher = OpenSSL::Cipher.new('AES-256-CBC')
    end
      
    def encrypt(password, clear_data)
      iv  = generate_iv

      @cipher.encrypt
      @cipher.key = Digest::SHA256.digest(password)
      @cipher.iv  = iv

      encrypted = @cipher.update(clear_data) + @cipher.final
      encrypted_with_iv = prefix_iv(iv, encrypted) 
      Base64.strict_encode64(encrypted_with_iv)
    end

    def decrypt(password, secret_data_with_iv)
      iv_encrypted = Base64::decode64(secret_data_with_iv)
      iv, encrypted = extract_iv_and_encrypted(iv_encrypted)

      @cipher.decrypt
      @cipher.key = Digest::SHA256.digest(password)
      @cipher.iv = iv
      @cipher.update(encrypted) + @cipher.final
    end

    private

    def prefix_iv(iv, encrypted)
      iv + encrypted
    end

    def generate_iv
      OpenSSL::Random.random_bytes(16)
    end
 
    def extract_iv_and_encrypted(iv_encrypted)
      iv = iv_encrypted[0..15]
      encrypted = iv_encrypted[16..-1]
      [iv, encrypted]
    end
  end
end
