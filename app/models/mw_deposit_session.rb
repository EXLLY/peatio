class MwDepositSession < ActiveRecord::Base
    belongs_to :deposit, required: true
end

# == Schema Information
# Schema version: 20190103030458
#
# Table name: mw_deposit_sessions
#
#  id               :integer          not null, primary key
#  txid             :string(36)
#  member_id        :integer
#  amount           :decimal(32, 16)
#  received_payload :text(65535)
#  response_payload :text(65535)
#  output           :string(33)
#  inputs           :string(33)       default("--- []\n")
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  deposit_id       :integer
#
# Indexes
#
#  index_mw_deposit_sessions_on_deposit_id  (deposit_id)
#  index_mw_deposit_sessions_on_member_id   (member_id)
#
# Foreign Keys
#
#  fk_rails_a25488ac4f  (deposit_id => deposits.id)
#
