# encoding: UTF-8
# frozen_string_literal: true

module Private
  class DepositsController < BaseController
    before_action :deposits_must_be_permitted!

    def gen_address
      current_user.ac(currency).payment_address
      head 204
    end

    def destroy
      record = current_user.deposits.find(params[:id]).lock!
      if record.cancel!
        head 204
      else
        head 422
      end
    end

    def upload
      file = params[:file].tempfile
      f = File.read(file)

      data = JSON.parse(f)
      Rails.logger.debug data
      if MwDepositSession.find_by(txid: data["id"]) != nil
        return head 409
      end
      currency = Currency.find_by(id: params[:currency])
      base_factor = currency.base_factor
      amount = data["amount"] / base_factor
      fee = data["fee"] / base_factor
      deposit = Deposits::MwCoin.create!(member_id: current_user.id, amount: amount, fee: fee, currency_id: currency.id)
      deposit_session = MwDepositSession.create!(
        txid: data["id"],
        member_id: current_user.id,
        received_payload: data.to_json(),
        amount: amount,
        deposit: deposit,
      )

      # TODO: Enqueue

      head 201
    end

    def download
      response = MwDepositSession.find_by(member_id: current_user.id, deposit_id: params[:deposit_id])
      if response == nil
        return head 404
      end
      send_data response["response_payload"], :filename => "#{response.deposit_id}.response.json"
    end

  private

    def currency
      @currency ||= Currency.enabled.find(params[:currency])
    end
  end
end
