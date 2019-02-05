namespace :arg do
  namespace :university_names do
    task provinces: :environment do
      desc 'Updates university names from "Otras Ciudades"'

      universities = University.where(city: "Otras ciudades")

      universities.each do |university|
        # Universidad en X (Provincia)
        old_name = university.name
        university.name.gsub!("Universidad en ", "")
        university.name.gsub!(" (Provincia)", "")
        puts "Updated #{old_name} with #{university.name}" if university.save
      end
    end
  end
end

