# encoding: UTF-8
# frozen_string_literal: true

module BlockchainService
  class Grin < Base
    # Rough number of blocks per hour for Grin is 60.
    def process_blockchain(blocks_limit: 60, force: false)
      latest_block = client.latest_block_number

      # Don't start process if we didn't receive new blocks.
      if blockchain.height + blockchain.min_confirmations >= latest_block && !force
        Rails.logger.info { "Skip synchronization. No new blocks detected height: #{blockchain.height}, latest_block: #{latest_block}" }
        return
      end

      from_block   = blockchain.height || 0
      to_block     = [latest_block, from_block + blocks_limit].min

      (from_block..to_block).each do |block_id|
        Rails.logger.info { "Started processing #{blockchain.key} block number #{block_id}." }

        block_json = client.get_block(block_id)

        next if block_json.blank? || block_json['outputs'].blank?

        block_data = { id: block_id }
        block_data[:deposits]    = build_deposits(block_json)
        block_data[:withdrawals] = build_withdrawals(block_json)

        save_block(block_data, latest_block)

        Rails.logger.info { "Finished processing #{blockchain.key} block number #{block_id}." }
      end
    rescue => e
      report_exception(e)
      Rails.logger.info { "Exception was raised during block processing." }
    end

    private

    def build_deposits(block_json)
      height = block_json.fetch('header').fetch('height')
      block_json
        .fetch('outputs')
        .each_with_object([]) do |block_txn, deposits|
          
          # bypass non transaction type outputs
          output_type = block_txn.fetch('output_type')
          next unless output_type == 'Transaction'

          output_commit = block_txn.fetch('commit')

          deposit_address_where(currency: :grin , address: output_commit, state: :responded) do |deposit|
            amount = deposit[:amount]
            if amount <= deposit.currency.min_deposit_amount
              Rails.logger.info "Skipted deposit with amount #{amount} with commit #{output_commit} at #{height}"
              next
            end
            
            Rails.logger.info "deposit is #{deposit[:address]}. value is #{deposit[:amount]}"

            deposits << {
              txid:    output_commit,
              address: output_commit,
              amount:  amount,
              block_number: height
            }
          end
      end
    end

    def build_withdrawals(block_json)
      height = block_json.fetch('header').fetch('height')
      block_json
        .fetch('outputs')
        .each_with_object([]) do |block_txn, withdrawals|
          output_commit = block_txn.fetch('commit')

          withdraw_address_where(currency: :grin , txid: output_commit) do |withdraw|
              amount = withdraw[:amount]
              Rails.logger.info "withdrawl is #{withdraw}"

          withdrawals << {
            txid:    output_commit,
            address: output_commit,
            amount: amount,
            block_number: height
          }   
          end
      end
    end


    def deposit_address_where(options = {})
      Deposit
        .where(options)
        .each do |deposit|
          yield deposit if block_given?
        end
    end

    def withdraw_address_where(options = {})
      Withdraws::Coin
        .where(options)
        .each do |deposit|
          yield withdraw if block_given?
        end
    end

  end
end