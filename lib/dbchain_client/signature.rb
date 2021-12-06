require 'secp256k1'

module DbchainClient
  class MyECDSA < Secp256k1::BaseKey
    include Secp256k1::Utils, Secp256k1::ECDSA

    def initialize
      super(nil, Secp256k1::ALL_FLAGS)
    end
  end

  class Signature
    def self.sign(private_key, message)
      raw_key = Secp256k1::Utils.decode_hex(private_key)
      pk = Secp256k1::PrivateKey.new(privkey: raw_key)
      pk.ecdsa_sign_recoverable(message) # signture is recoverable one
    end

    # signture is recoverable one
    def self.verify(signature, message)
      unrelated = MyECDSA.new
      raw_sig = unrelated.ecdsa_recoverable_convert(signature)

      recovered_pubkey = unrelated.ecdsa_recover message, signature 
      pubkey = Secp256k1::PublicKey.new(pubkey: recovered_pubkey)
      pubkey.ecdsa_verify(message, raw_sig)
    end
  end
end
