module JsonHelper
  def get_json(name)
    js = File.read(Rails.root.join 'spec', 'fixtures', 'json', "#{name}.json")
    JSON.parse(js, object_class: OpenStruct)
  end
end