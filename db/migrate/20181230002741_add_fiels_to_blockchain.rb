class AddFielsToBlockchain < ActiveRecord::Migration
  def change
    add_column :blockchains, :username, :string
    add_column :blockchains, :secret, :string
  end
end
