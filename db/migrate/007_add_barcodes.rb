class AddBarcodes < ActiveRecord::Migration
  def change
    create_table :barcodes do |t|
      t.belongs_to :paint
      t.string :barcode
      t.timestamps
    end
  end
end
