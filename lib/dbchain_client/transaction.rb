require 'json'
require 'base64'
require 'net/http'
require_relative 'message_generator'

module DbchainClient
  class Transaction
    def initialize(base_url, chain_id, private_key_hex)
      @rest_lib = DbchainClient::RestLib.new(base_url)
      @chain_id = chain_id
      @private_key = PrivateKey.new(private_key_hex)
      @from_address = @private_key.public_key.address
    end
 
    def sign_and_broadcast(messages, gas: '99999999', memo: '')
      tx = {
        fee: {
          amount: [],
          gas:    gas
        },
        memo: memo,
        msg: messages
      }

      sign_message = make_sign_message(tx, messages)
      signature = @private_key.sign(sign_message)
      signed_tx = {
        signature: Base64.strict_encode64([signature].pack("H*")),
        pub_key:   {
            type:  'tendermint/PubKeySecp256k1',
            value: Base64.strict_encode64([@private_key.public_key.public_key_hex].pack("H*"))
        }
      }

      tx[:signatures] = [signed_tx]
      broadcastBody = {
        tx: tx,
        mode: 'async'
      }.to_json

      response = rest_post("/txs", broadcastBody)
      response#.data.txhash
    end

    private

    def make_sign_message(tx, messages)
      account = get_account
      sign_obj = {
        account_number: account["account_number"],
        chain_id:       @chain_id,
        fee:            tx[:fee],
        memo:           tx[:memo],
        msgs:           tx[:msg],
        sequence:       account["sequence"]
      }
      to_deep_sorted_json(sign_obj)
    end

    def get_account
      response = rest_get("/auth/accounts/#{@from_address}")
      account = JSON.parse(response.body)
      return account['result']['value']
    end

    def rest_get(url)
      @rest_lib.rest_get(url)
    end

    def rest_post(url, data)
      @rest_lib.rest_post(url, data)
    end

    def to_deep_sorted_json(obj)
      if obj.instance_of?(Array)
        return '[' + obj.map{|o|to_deep_sorted_json(o)}.join(',') + ']'
      end

      if obj.instance_of?(Hash)
        keys = obj.keys.sort
        return '{' + keys.map{|k| JSON.generate(k) + ':' + to_deep_sorted_json(obj[k])}.join(',') + '}'
      end

      JSON.generate(obj)
    end
  end
end
