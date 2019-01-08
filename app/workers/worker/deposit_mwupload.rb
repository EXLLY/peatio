# encoding: UTF-8
# frozen_string_literal: true

module Worker
  class DepositMwupload

    # payalod
    # {
    #    'id': 1234 // deposit id
    # }

    # TODO: handle error cases!!!

    def process(payload)
      deposit_id = payload['id']
      if deposit_id == nil
        Rails.logger.error { "Received request for mimblewimble upload at #{Time.now} deposit_id missing." }
        return
      end

      Rails.logger.debug { "Received request for mimblewimble upload at #{Time.now} deposit_id: #{deposit_id}." }

      session = MwDepositSession::find_by(deposit_id: deposit_id)
      if session == nil
        Rails.logger.error {"Failed to fetch mw_despoit_session by deposit_id: #{deposit_id}"}
        return
      end
      if session.response_payload != nil
        Rails.logger.error {"Mw desposit is already processed deposit_id: #{deposit_id}"}
        return
      end
      if session.received_payload == nil
        Rails.logger.error {"Mw desposit missing received_payload deposit_id: #{deposit_id}"}
        return
      end

      deposit = Deposits::MwCoin::find_by(id: deposit_id)
      if deposit == nil
        Rails.logger.error {"Failed to fetch deposit(MwCoin) by deposit_id: #{deposit_id}"}
        return
      end

      received_payload = JSON.parse(session.received_payload)
      wallet = WalletClient[deposit.currency.wallet(:deposit)]
      respones = wallet.receive_tx(received_payload)

      #find out output address
      existing_outputs = received_payload['tx']['body']['outputs'].map {|o| o['commit'].pack('C*').unpack('H*')[0]}
      respond_outputs = respones['tx']['body']['outputs'].map {|o| o['commit'].pack('C*').unpack('H*')[0]}
      output = respond_outputs.reject{|x| existing_outputs.include? x}
      if output.length != 1
        Rails.logger.error {"Mw desposit output response length not equal to 1, length: #{output.length}"}
        deposit.reject
        deposit.save
        return
      end

      session.response_payload = respones.to_json()
      session.save

      deposit.address = output[0]
      deposit.respond
      deposit.save

      rescue Exception => e
        begin
            Rails.logger.error { "Failed to process upload. See exception details below." }
            report_exception(e)
        end
    end
  end
end
