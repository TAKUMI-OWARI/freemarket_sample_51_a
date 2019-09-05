class RemoveProductImageIdFromProducts < ActiveRecord::Migration[5.2]
  def change
    remove_column :products, :product_image_id, :bigint, null:false
  end
end
