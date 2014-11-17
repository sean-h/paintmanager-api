class AddCompatibilityGroups < ActiveRecord::Migration
  def change
    create_table :compatibility_groups do |t|
      t.integer :group_id
      t.timestamps
    end

    create_table :compatibility_paints do |t|
      t.belongs_to :compatibility_groups
      t.belongs_to :paint
      t.timestamps
    end
  end
end
