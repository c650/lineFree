class RemoveColumnTypeFromPlaces < ActiveRecord::Migration
  def up
  	remove_column :places, :type
  end

  def down
  	addd_column :places, :type, :string
  end
end
