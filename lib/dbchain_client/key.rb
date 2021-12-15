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
      compact_sig = Secp256k1::Utils.decode_hex(signature)
      raw_sig = @public_key.ecdsa_deserialize_compact(compact_sig)
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
      compact_sig = @private_key.ecdsa_serialize_compact(raw_sig)
      Secp256k1::Utils.encode_hex(compact_sig)
    end
  end
end
