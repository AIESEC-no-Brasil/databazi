namespace :arg do
  desc "Arg related tasks"
  @universities = ''
  @cities = ''
  @committees = ''
  task import_json_data: :environment do
    desc "Creates universities, and committees based on imported json"

    create_local_committees_csv

    load_json

    CSV.open('files/arg_universities.csv', 'a+') do |csv|
      csv << ['name', 'city', 'local_committee_id']

      university = {}
      @universities.each do |university_json|
        university['name'] =
          university_json['nombre_universidad']
        university['city'] =
          get_city_name(university_json['nombre_universidad'])
        university['local_committee_id'] =
          create_local_committee(university_json['nombre_universidad'])

        csv << university.each_with_index.map { |(k,v), index| v }

        if University.create(podio_id: 0,
                             name: university['name'],
                             city: university['city'],
                             local_committee_id:
                              university['local_committee_id'])

          puts "Created #{university['name']} university."
        end
      end
    end
  end
end

def offset(index)
  index * 20
end

def create_local_committees_csv
  CSV.open('files/arg_local_committees.csv', 'a+') do |csv|
      csv << ['name', 'expa_id']
  end
end

# Use the github JSON of citys to join city name to the universities - uses university json too
def get_city_name(university_name)
  university = @universities.select {|university| university["nombre_universidad"] == university_name }[0]
  return nil? if university.nil?
  city = @cities.select {|city| city["id_ciudad"] == university["id_ciudad"] }[0]
  city["nombre_ciudad"]
end

# Use the github JSON of committee to join committee_local_id to the universities - uses university json too
def get_expa_committee_id(university_name)
  university = @universities.select {|university| university["nombre_universidad"] == university_name }[0]
  return nil? if university.nil?
  committee = @committees.select {|committee| committee["id_podio"] == university["c_id_podio"] }[0]
  committee["id_expa"]
end

def create_local_committee(university_name)
  university = @universities.select {|university| university["nombre_universidad"] == university_name }[0]

  return nil if university.nil?

  committee = @committees.select {|committee| committee['id_podio'] == university["c_id_podio"] }[0]

  local_committee = LocalCommittee.find_by(name: committee['nombre_comite'])

  if local_committee
    local_committee.update_attributes(expa_id: committee['id_expa'])
  else
    LocalCommittee.create(name: committee['nombre_comite'],
                          expa_id: committee['id_expa'],
                          podio_id: 0)

    CSV.open('files/arg_local_committees.csv', 'a+') do |csv|
      csv << [committee['nombre_comite'], committee['id_expa']]
    end
  end

  local_committee.try(:id) || LocalCommittee.last.id
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

def update_committee_podio_id(entries, csv)
  committee = {}
  entries.each do |entry|
    committee['podio_id'] = entry.item_id
    committee['name'] = strip_html_tags(entry.fields[0]['values'][0]['value'])
    row = committee.each_with_index.map { |(k,v), index| v }
    csv << row

    if LocalCommittee.update(podio_id: committee['podio_id'])
      puts "Updated #{committee['name']} committee."
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

def load_json
  @cities = JSON.parse(HTTParty
    .get("https://raw.githubusercontent.com/aiesec-argentina/forms/master/A"\
      "IESECserver_new/data/ciudades.json")
    .body)
  @universities = JSON.parse(HTTParty.get("https://raw.githubusercontent.com/aiesec-argentina/forms/master/A"\
      "IESECserver_new/data/universidades.json").body)
  @committees = JSON.parse(HTTParty.get("https://raw.githubusercontent.com/aiesec-argentina/forms/master/A"\
      "IESECserver_new/data/comites.json").body)
end
