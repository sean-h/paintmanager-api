class Init < ActiveRecord::Migration
  def change
    create_table :brands do |t|
      t.string :name
      t.timestamps
    end
    
    create_table :ranges do |t|
      t.string :name
      t.belongs_to :brand, index: true
      t.timestamps
    end

    create_table :paints do |t|
      t.string :name
      t.string :color
      t.belongs_to :range, index: true
      t.timestamps
    end

    create_table :users do |t|
      t.string :email
      t.string :password
      t.timestamps
    end
  end
end
