require "bitcoin"

module DbchainClient
  class Mnemonics
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

      def generate_private_key
        mnemonic = generate_mnemonic
        master_key = mnemonic_to_master_key(mnemonic)
        master_key_to_cosmos_key_pair(master_key)[0]
      end

      def public_key_to_address(pub_key)
        hash160 = Bitcoin.hash160(pub_key)
        words = Bitcoin::Bech32.convert_bits(hash160.htb.unpack("C*"), from_bits: 8, to_bits: 5, pad: true)
        Bitcoin::Bech32.encode("cosmos", words)
      end
    end
  end
end
