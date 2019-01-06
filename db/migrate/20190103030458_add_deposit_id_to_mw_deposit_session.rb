class AddDepositIdToMwDepositSession < ActiveRecord::Migration
  def change
    add_reference :mw_deposit_sessions, :deposit, index: true, foreign_key: true
  end
end
