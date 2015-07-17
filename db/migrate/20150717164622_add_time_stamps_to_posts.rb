class AddTimeStampsToPosts < ActiveRecord::Migration
  def up
  	add_column :posts, :created_at, :datetime
  end

  def down
  	remove_column :posts, :created_at, :datetime
  end
end
