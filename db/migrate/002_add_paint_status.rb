class AddPaintStatus < ActiveRecord::Migration
  def change
    create_table :status_keys do |t|
      t.string :name
      t.string :color
      t.timestamps
    end
    create_table :paint_statuses do |t|
      t.belongs_to :paint
      t.belongs_to :user
      t.integer :status
      t.timestamps
    end
  end
end
