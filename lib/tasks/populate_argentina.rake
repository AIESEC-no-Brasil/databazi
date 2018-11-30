namespace :fetch_podio do
  desc "Retrieve Universities, Courses and Committees from Podio"

  task universities: :environment do
    desc "Create universities on local database and export to a csv file"

    UNIVERSITY_APP_ID = 21_949_601

    setup_podio
    authenticate_podio

    page = Podio::Item.find_all(UNIVERSITY_APP_ID, :limit => 20)
    entry_count = page.count
    page_index = 1

    CSV.open('files/arg_universities.csv', 'a+') do |csv|
      csv << ['podio_id', 'name']
      create_university_page(page.all, csv)

      while (offset(page_index) < entry_count) do
        page = Podio::Item.find_all(UNIVERSITY_APP_ID, :limit => 20, offset: offset(page_index))
        page_index += 1
        create_university_page(page.all, csv)
      end
    end
  end

  task courses: :environment do
    desc "Create courses on local database and export to a csv file"

    COURSE_APP_ID = 21_949_641

    setup_podio
    authenticate_podio

    page = Podio::Item.find_all(COURSE_APP_ID, :limit => 20)
    entry_count = page.count
    page_index = 1

    CSV.open('files/arg_courses.csv', 'a+') do |csv|
      csv << ['podio_id', 'name']
      create_course_page(page.all, csv)

      while (offset(page_index) < entry_count) do
        page = Podio::Item.find_all(COURSE_APP_ID, :limit => 20, offset: offset(page_index))
        page_index += 1
        create_course_page(page.all, csv)
      end
    end
  end

  task committees: :environment do
    desc "Create committees on local database and export to a csv file"

    COMMITTEE_APP_ID = 21_949_636

    setup_podio
    authenticate_podio

    page = Podio::Item.find_all(COMMITTEE_APP_ID, :limit => 20)
    entry_count = page.count
    page_index = 1

    CSV.open('files/arg_local_committees.csv', 'a+') do |csv|
      csv << ['podio_id', 'name']
      create_committee_page(page.all, csv)

      while (offset(page_index) < entry_count) do
        page = Podio::Item.find_all(COMMITTEE_APP_ID, :limit => 20, offset: offset(page_index))
        page_index += 1
        create_committee_page(page.all, csv)
      end
    end
  end
end

def offset(index)
  index * 20
end

def create_university_page(entries, csv)
  university = {}
  entries.each do |entry|
    university['podio_id'] = entry.item_id
    university['name'] = strip_html_tags(entry.fields[0]['values'][0]['value'])
    row = university.each_with_index.map { |(k,v), index| v }
    csv << row

    if University.create(podio_id: university['podio_id'], name: university['name'])
      puts "Created #{university['name']} university."
    end
  end
end

def create_course_page(entries, csv)
  course = {}
  entries.each do |entry|
    course['podio_id'] = entry.item_id
    course['name'] = strip_html_tags(entry.fields[0]['values'][0]['value'])
    row = course.each_with_index.map { |(k,v), index| v }
    csv << row

    if CollegeCourse.create(podio_id: course['podio_id'], name: course['name'])
      puts "Created #{course['name']} course."
    end
  end
end

def create_committee_page(entries, csv)
  committee = {}
  entries.each do |entry|
    committee['podio_id'] = entry.item_id
    committee['name'] = strip_html_tags(entry.fields[0]['values'][0]['value'])
    row = committee.each_with_index.map { |(k,v), index| v }
    csv << row

    if LocalCommittee.create(podio_id: committee['podio_id'],
                                            name: committee['name'],
                                            expa_id: 0)
      puts "Created #{committee['name']} committee."
    end
  end
end

def strip_html_tags(string)
  ActionView::Base.full_sanitizer.sanitize(string)
end

def authenticate_podio
  Podio.client.authenticate_with_credentials(
    ENV['PODIO_USERNAME'],
    ENV['PODIO_PASSWORD']
  )
end

def setup_podio
  Podio.setup(
    api_key: ENV['PODIO_API_KEY'],
    api_secret: ENV['PODIO_API_SECRET']
  )
end

