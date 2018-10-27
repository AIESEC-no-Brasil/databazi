class EmptyController < ApplicationController
  def index
    render plain: 'Success'
  end
end
