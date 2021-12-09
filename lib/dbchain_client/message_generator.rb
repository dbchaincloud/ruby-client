module DbchainClient
  class MessageGenerator 
    def initialize(from_address)
      @from_address = from_address
    end

    def run(message_name, message_hash)
      if message_name == 'MsgSend'
        type = 'cosmos-sdk/MsgSend'
        message_hash[:from_address] = @from_address
      else
        type = "dbchain/#{message_name}"
        message_hash[:owner] = @from_address
      end
    
      return { type: type, value: message_hash }
    end
  end
end
