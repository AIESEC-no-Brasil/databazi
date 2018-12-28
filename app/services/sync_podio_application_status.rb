class SyncPodioApplicationStatus
  def self.call
    new.call
  end
  def call
    puts 'hello world'
    last_applications(last_updated)
  end

  private

  def last_updated
    SyncParam.first&.updated_at || 3.month.ago.round
  end

  def last_applications(from)
    puts 'call last_applications'
    Expa::Application.where(updated_at: from)
  end
end