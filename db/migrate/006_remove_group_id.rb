class RemoveGroupId < ActiveRecord::Migration
  def change
    remove_column :compatibility_groups, :group_id
  end
end
