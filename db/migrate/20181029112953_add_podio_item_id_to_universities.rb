class AddPodioItemIdToUniversities < ActiveRecord::Migration[5.2]
  def change
    add_column :universities, :podio_item_id, :string
  end
end
