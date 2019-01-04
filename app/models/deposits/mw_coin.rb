# encoding: UTF-8
# frozen_string_literal: true

module Deposits
  class MwCoin < Deposit
    include HasOneBlockchainThroughCurrency

    validate { errors.add(:currency, :invalid) if currency && !currency.coin? }

    before_validation do
      next if blockchain_api&.case_sensitive?
      self.txid = txid.try(:downcase)
      self.address = address.try(:downcase)
    end

    before_validation do
      next unless blockchain_api&.supports_cash_addr_format? && address?
      self.address = CashAddr::Converter.to_cash_address(address)
    end

    def response_file_url
        session = MwDepositSession.find_by(deposit_id: id)
        if session == nil
            Rails.logger.error "Can not find deposit session,  deposit id: #{id}"
            return nil
        end
        if session.response_payload == nil
            return nil
        end
        return "/deposits/#{currency_id}/download/#{id}"
    end

    def as_json(*)
      super.merge!(
        response_file_url: response_file_url,
        transaction_url: transaction_url,
        confirmations:   confirmations
      )
    end

    def as_json_for_event_api
      super.merge blockchain_confirmations: confirmations
    end

    def isMw
        return true
    end
  end
end

# == Schema Information
# Schema version: 20190103015526
#
# Table name: deposits
#
#  id           :integer          not null, primary key
#  member_id    :integer          not null
#  currency_id  :string(10)       not null
#  amount       :decimal(32, 16)  not null
#  fee          :decimal(32, 16)  not null
#  address      :string(95)
#  txid         :string(128)
#  txout        :integer
#  aasm_state   :string(30)       not null
#  block_number :integer
#  type         :string(30)       not null
#  tid          :string(64)       not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  completed_at :datetime
#
# Indexes
#
#  index_deposits_on_aasm_state_and_member_id_and_currency_id  (aasm_state,member_id,currency_id)
#  index_deposits_on_currency_id                               (currency_id)
#  index_deposits_on_currency_id_and_txid_and_txout            (currency_id,txid,txout) UNIQUE
#  index_deposits_on_member_id_and_txid                        (member_id,txid)
#  index_deposits_on_tid                                       (tid)
#  index_deposits_on_type                                      (type)
#
