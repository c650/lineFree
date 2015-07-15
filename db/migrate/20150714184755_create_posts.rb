class CreatePosts < ActiveRecord::Migration
  def up
  	create_table :posts do |t|
  		t.integer :place_id
  		t.integer :user_id
  		t.string :wait_time
  		t.string :people_in_line
  	end
  end

  def down
  	drop_table :posts
  end
end
