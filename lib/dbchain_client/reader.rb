require 'json'
require 'base58'

module DbchainClient
  class Reader
    def initialize(base_url, private_key, address=nil)
      @rest_lib = DbchainClient::RestLib.new(base_url)

      if private_key.instance_of? String
        @private_key = PrivateKey.new(private_key)
      else
        @private_key = private_key
      end

      @public_key = @private_key.public_key
      @from_address = address || @public_key.address
    end

    def generate_access_code(time=nil)
      encoded_public_key = Base58.binary_to_base58(@public_key.to_raw, :bitcoin)
      time ||= (Time.now.to_f * 1000).to_i.to_s
      signature = @private_key.sign(time)
      encoded_signature = Base58.binary_to_base58(signature.compact, :bitcoin)
      "#{encoded_public_key}:#{time}:#{encoded_signature}"
    end
  end
end
