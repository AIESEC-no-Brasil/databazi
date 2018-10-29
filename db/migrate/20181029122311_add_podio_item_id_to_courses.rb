class AddPodioItemIdToCourses < ActiveRecord::Migration[5.2]
  def change
    add_column :college_courses, :podio_item_id, :string
  end
end
