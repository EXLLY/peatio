class MwDepositSession < ActiveRecord::Base
end

# == Schema Information
# Schema version: 20181228000422
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
#
# Indexes
#
#  index_mw_deposit_sessions_on_member_id  (member_id)
#
