class ExpaICXSync
  def self.call(from, to, page)
    new.call(from, to, page)
  end

  def call(from, to, page)
    Repos::Expa.load_icx_applications(from, to, page).each do |application|
      puts 'Returned'
      RepositoryPodio.save_icx_application(application)
    end
    true
  end
end