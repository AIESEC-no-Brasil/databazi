module PodioHelper
  def map_podio(item)
    mapped = {}
    item.fields.each do |field|
      key = field['external_id'].intern
      if field['values'][0]['value'].kind_of? String
        value = field['values'][0]['value']
        if (field['type'] == 'number')
          value = Float(value)
        end
        mapped[key] = value
      elsif field['type'] == 'date'
        date = Date.parse(field['values'][0]['start'])
        mapped[key] = date
      elsif mapped[key] = field['values'][0]['value'].key?('item_id')
        mapped[key] = field['values'][0]['value']['item_id']
      else
        mapped[key] = field['values'][0]['value']['id']
      end
    end
    mapped
  end
end