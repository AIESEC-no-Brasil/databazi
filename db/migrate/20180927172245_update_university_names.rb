class UpdateUniversityNames < ActiveRecord::Migration[5.2]
  def up
    University.all.each do |university|
      university.update_attributes(name: university.name.upcase)
    end
  end

  def down; end
end
