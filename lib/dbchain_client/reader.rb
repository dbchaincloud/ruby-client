require 'json'
require 'base58-alphabets'

module DbchainClient
  class Reader
    QueryRoot = '/dbchain'

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

    def get_row(app_code, table_name, id)
      uri = uri_builder("find", app_code, table_name, id)
      response = @rest_lib.rest_get(uri)
      h = JSON.parse(response.body)
      return h['result']
    end

    def generate_access_code(time=nil)
      encoded_public_key = Base58.encode_bin(@public_key.to_raw)
      time ||= (Time.now.to_f * 1000).to_i.to_s
      signature = @private_key.sign(time)
      encoded_signature = Base58.encode_bin(signature.compact)
      "#{encoded_public_key}:#{time}:#{encoded_signature}"
    end

    def uri_builder(*args)
      raise "At least one parameter is needed!" if args.size < 1
      access_token = generate_access_code
      args.insert(1, access_token)
      args.unshift(QueryRoot)
      args.join('/')
    end
  end
end
