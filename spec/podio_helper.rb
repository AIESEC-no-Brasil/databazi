module PodioHelper
  def map_podio(item)
    mapped = {}
    item.fields.each do |field|
      if field['values'][0]['value'].kind_of? String
        mapped["#{field['external_id']}".intern] = field['values'][0]['value']
      else
        mapped["#{field['external_id']}".intern] = field['values'][0]['value']['id']
      end
    end
    mapped
  end
end