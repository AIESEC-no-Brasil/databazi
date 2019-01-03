require 'rails_helper'
require "#{::Rails.root}/app/repos/expa"

RSpec.describe Repos::Expa do

  it '#load_icx_applications' do
    described_class.load_icx_applications(1.week.ago, 1.day.ago, 0)
  end
end