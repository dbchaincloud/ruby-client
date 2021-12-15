require 'json'
require 'base64'
require 'net/http'
require_relative 'message_generator'

module DbchainClient
  class RestLib
    def initialize(base_url)
      @base_url = base_url
    end

    def rest_get(url)
      uri = URI(@base_url + url)
      res = Net::HTTP.get_response(uri)
      res
    end

    def rest_post(url, data)
      uri = URI(@base_url + url)
      req = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json')
      req.body = data
      http = Net::HTTP.new(uri.host, uri.port)
      res = http.request(req)
      res.body
    end
  end
end
