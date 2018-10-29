namespace :update_podio do
  desc "Update Podio ids"

  task universities: :environment do
    desc "Update universities"

    setup_podio
    authenticate_podio

    page = Podio::Item.find_all(14_568_134, :limit => 20)
    entry_count = page.count
    page_index = 1

    update_university_page(page.all)

    while (offset(page_index) < entry_count) do
      page = Podio::Item.find_all(14_568_134, :limit => 20, offset: offset(page_index))
      page_index += 1
      update_university_page(page.all)
    end
  end

  task courses: :environment do
    desc "Update courses"

    setup_podio
    authenticate_podio

    page = Podio::Item.find_all(14_568_143, :limit => 20)
    entry_count = page.count
    page_index = 1

    update_course_page(page.all)

    while (offset(page_index) < entry_count) do
      page = Podio::Item.find_all(14_568_143, :limit => 20, offset: offset(page_index))
      page_index += 1
      update_course_page(page.all)
    end
  end
end

def offset(index)
  index * 20
end

def update_university_page(entries)
  entries.each do |entry|
    university = University.find_by(podio_id: entry.app_item_id_formatted)
    if university
      p "University #{university.name}"
      university.update(podio_item_id: entry.item_id)
    end
  end
end

def update_course_page(entries)
  entries.each do |entry|
    course = CollegeCourse.find_by(podio_id: entry.app_item_id_formatted)
    if course
      p "Course #{course.name}"
      course.update(podio_item_id: entry.item_id)
    end
  end
end

def authenticate_podio
  Podio.client.authenticate_with_credentials(
    Rails.application.credentials.podio_username,
    Rails.application.credentials.podio_password
  )
end

def setup_podio
  Podio.setup(
    api_key: Rails.application.credentials.podio_api_key,
    api_secret: Rails.application.credentials.podio_api_secret
  )
end
