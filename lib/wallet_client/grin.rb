# encoding: UTF-8
# frozen_string_literal: true

module WalletClient
    class Grin < Base
        def initialize(*)
            super
            @endpoint = URI.parse(wallet.uri)
        end
        
        def receive_tx(data)
            post('/v1/wallet/foreign/receive_tx', data)
        end

        def block_height()
            get('/v1/wallet/owner/node_height')
        end 

        private
        def get(path)
            conn = Faraday.new(url: @endpoint)
            conn.basic_auth(wallet.username, wallet.secret)
            response = conn.get(path)    
            response.assert_success!
            JSON.parse(response.body)            
        end

        def post(path, data = nil)
            conn = Faraday.new(url: @endpoint)
            conn.basic_auth(wallet.username, wallet.secret)
            if data 
                data = data.compact
            end
            response = conn.post(path, data)    
            response.assert_success!
            JSON.parse(response.body)            
        end

    end
end
