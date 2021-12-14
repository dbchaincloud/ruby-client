require 'json'
require 'base64'
require 'net/http'
require_relative 'message_generator'

module DbchainClient
  class Writer 
    def initialize(base_url, chain_id, private_key_hex, address=nil)
      @transaction = DbchainClient::Transaction.new(base_url, chain_id, private_key_hex)
      from_address = address || PrivateKey.new(private_key_hex).public_key.address
      @message_generator = DbchainClient::MessageGenerator.new(from_address)
    end
  
    def send_token(to_address, amount)
      message = @message_generator.run('MsgSend',
        to_address: to_address,
        amount: [{denom: 'dbctoken', amount: amount.to_string}]
      )
      @transaction.sign_and_broadcast([message])
    end

    def insert_row(app_code, table_name, fields)
      fields_str = Base64.strict_encode64(fields.to_json)
      message = @message_generator.run('InsertRow',
        app_code: app_code,
        table_name: table_name,
        fields: fields_str
      )
      @transaction.sign_and_broadcast([message])
    end
  end
end
