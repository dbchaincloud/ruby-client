#require "bitcoin"
require "secp256k1"

module DbchainClient
  class PublicKey
    def initialize(pub_key) # hex or raw public key
      if pub_key.instance_of?(Secp256k1::PublicKey)
        @public_key = pub_key
      else
        raw_pub_key = Secp256k1::Utils.decode_hex(pub_key)
        @public_key = Secp256k1::PublicKey.new(pubkey: raw_pub_key, raw: true)
      end
    end

    def public_key_hex
      @public_key.serialize.unpack('H*')[0]
    end

    def to_raw
      @public_key.serialize
    end

    def to_s
      public_key_hex
    end

    def address
      @address ||= Mnemonics.public_key_to_address(public_key_hex)
    end

    def verify(message, signature)
      raw_sig = signature.raw
      @public_key.ecdsa_verify(message, raw_sig)
    end
  end

  class PrivateKey
    def initialize(private_key_hex)
      raw_key = Secp256k1::Utils.decode_hex(private_key_hex)
      @private_key = Secp256k1::PrivateKey.new(privkey: raw_key)
    end

    def public_key
      @public_key ||= PublicKey.new(@private_key.pubkey)
    end

    def sign(message)
      raw_sig = @private_key.ecdsa_sign(message)
      Signature.new(raw_sig)
    end
  end

  class Signature
    include Secp256k1::ECDSA

    def initialize(raw_sig)
      @raw_sig = raw_sig
    end

    def raw
      @raw_sig
    end

    def compact
      ecdsa_serialize_compact(@raw_sig)
    end

    def to_hex
      compact.unpack("H*")
    end
  end
end
