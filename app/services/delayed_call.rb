class DelayedCall
  def self.call(params)
    new(params).call
  end

  attr_reader :status, :delay_in_seconds

  def initialize(params)
    @status = true

    @delay_in_seconds = params[:delay]
    @job = params[:job]
  end

  def call
    sleep @delay_in_seconds
    @status = false unless execute_job
  end

  private

  def execute_job
   @job.constantize.call
  end
end
