require "bitcoin"
require "secp256k1"

module MyExtension
  def get_public_key
    if pubkey.nil?
      update_public_key
    end
    pubkey
  end
end

Secp256k1::PrivateKey.include MyExtension

module DbchainClient
  class Key
    def initialize(private_key_hex)
      raw_key = Secp256k1::Utils.decode_hex(private_key_hex)
      @private_key = Secp256k1::PrivateKey.new(privkey: raw_key)
    end

    def public_key
      @public_key ||= @private_key.get_public_key
    end

    def address
      @address ||= Key.public_key_to_address(public_key)
    end

    class << self
      def generate_mnemonic(strength_bits = 128)
        Bitcoin::Trezor::Mnemonic.generate(strength_bits)
      end

      def mnemonic_to_master_key(mnemonic)
        seed = Bitcoin::Trezor::Mnemonic.to_seed(mnemonic)
        Bitcoin::ExtKey.generate_master(seed.htb)
      end

      def master_key_to_cosmos_key_pair(master_key)
        # m/44'/118'/0'/0/0"
        key = master_key.derive(2**31 + 44).derive(2**31 + 118).derive(2**31).derive(0 ).derive(0)
        [key.priv, key.pub]
      end

      def public_key_to_address(pub_key)
        hash160 = Bitcoin.hash160(pub_key)
        words = Bitcoin::Bech32.convert_bits(hash160.htb.unpack("C*"), from_bits: 8, to_bits: 5, pad: true)
        Bitcoin::Bech32.encode("cosmos", words)
      end
    end
  end
end
