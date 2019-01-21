class AddExemptionNumberToSpreeUsers < ActiveRecord::Migration[5.2]
  def change
    return if column_exists?(:spree_users, :exemption_number)

    add_column :spree_users, :exemption_number, :string
  end
end
