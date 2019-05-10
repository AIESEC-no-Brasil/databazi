class AddWhatsappLinkToLocalCommittees < ActiveRecord::Migration[5.2]
  def change
    add_column :local_committees, :whatsapp_link, :string
  end
end
