class AddHomeCityToUsers < ActiveRecord::Migration
  def up
  	add_column :users, :home_city, :string
  	add_column :users, :home_state, :string
  end

  def down
  	remove_column :users, :home_city
  	remove_column :users, :home_state
  end
end
