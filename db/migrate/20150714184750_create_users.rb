class CreateUsers < ActiveRecord::Migration
  def up 
  	create_table :users do |t|

  		t.string :first_name
  		t.string :last_name
  		t.string :email
  		t.string :username
  		t.string :phone_number
  		t.string :birthdate
      t.string :password_hash
  		
  	end
  end

  def down
  	drop_table :users
  end
end
