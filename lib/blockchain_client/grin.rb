# encoding: UTF-8
# frozen_string_literal: true

module BlockchainClient
    class Grin < Base
      def initialize(*)
        super
        @endpoint = URI.parse(blockchain.server)        
      end

      def block_height()
        data = get('/v1/chain')
        data['height']
      end 

      private

      def get(path)
          conn = Faraday.new(url: @endpoint)
          conn.basic_auth(blockchain.username, blockchain.secret)
          response = conn.get(path)    
          response.assert_success!
          JSON.parse(response.body)            
      end
    end
end
