class CreatePlaces < ActiveRecord::Migration
  def up 
  	create_table :places do |t|
  		t.string :name
  		t.string :type #restaurant or store?
  		t.string :address
  		t.string :city
  		t.string :state
      t.integer :zipcode
	end
  end	

  def down
  	drop_table :places
  end
end
