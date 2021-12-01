require "bitcoin"

module DbchainRubyClient
  class Key
    def self.generate_mnemonic(strength_bits = 128)
      Bitcoin::Trezor::Mnemonic.generate(strength_bits)
    end

    def self.mnemonic_to_master_key(mnemonic)
      seed = Bitcoin::Trezor::Mnemonic.to_seed(mnemonic)
      Bitcoin::ExtKey.generate_master(seed.htb)
    end

    def self.master_key_to_cosmos_key_pair(master_key)
      # m/44'/118'/0'/0/0"
      key = master_key.derive(2**31 + 44).derive(2**31 + 118).derive(2**31).derive(0 ).derive(0)
      [key.priv, key.pub]
    end

    def self.public_key_to_address(pub_key)
      hash160 = Bitcoin.hash160(pub_key)
      words = Bitcoin::Bech32.convert_bits(hash160.htb.unpack("C*"), from_bits: 8, to_bits: 5, pad: true)
      Bitcoin::Bech32.encode("cosmos", words)
    end
  end
end
