class Experience < ApplicationRecord
  belongs_to :gt_participant

  def for_podio
    arr = []
    arr << 1 if language?
    arr << 2 if information_technology?
    arr << 3 if management?
    arr << 4 if marketing?

    arr
  end
end
