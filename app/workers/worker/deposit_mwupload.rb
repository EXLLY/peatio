# encoding: UTF-8
# frozen_string_literal: true

module Worker
    class DepositMwupload
      def process(payload)
        Rails.logger.info { "Received request for mimblewimble upload at #{Time.now} deposit_id: #{payload['id']}." }
      end
    end
  end
  