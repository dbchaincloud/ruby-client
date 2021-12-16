module DbchainClient
  class Querier
    def initialize(base_url, private_key, app_code=nil)
      @base_url = base_url

      if private_key.instance_of? String
        @private_key = PrivateKey.new(private_key)
      else
        @private_key = private_key
      end

      set_app_code unless app_code.nil?
      @single_value = false
    end

    def set_app_code(app_code)
      initialize_internal_querier if @q.nil?
      @q[:app_code] = app_code
    end

    def table(table_name)
      h = {
        method: 'table',
        table: table_name
      }
      finish(h)
    end

    def find(id)
      @single_value = true
      h = {
        method: 'find',
        id: id
      }
      finish(h)
    end

    def find_first
      @single_value = true
      h = {
        method: 'first',
      }
      finish(h)
    end

    def find_last
      @single_value = true
      h = {
        method: 'last',
      }
      finish(h)
    end

    def select(*args)
      h = {
        method: 'select',
        fields: args.join(',')
      }
      finish(h)
    end

    def where(field_name, value, operator)
      h = {
        method: 'where',
        field: field_name,
        value: value,
        operator: operator
      }
      finish(h)
    end

    def equal(field_name, value)
      where(field_name, value, '=')
    end

    def own()
      from_address = @private_key.public_key.address
      equal('created_by', from_address)
    end

    def run
      reader = DbchainClient::Reader.new(@base_url, @private_key)
      result = reader.querier(@q[:app_code], @q[:commands])
      if @single_value
        if result.size > 0
          result[0]
        else
          nil
        end
      else
        result
      end
    end

    private

    def initialize_internal_querier
      @q = {commands: []}
    end

    def finish(h)
      @q[:commands].push(h)
      self
    end
  end
end
