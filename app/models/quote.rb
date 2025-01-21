class Quote < ApplicationRecord
  # Exclude created_at and updated_at for all json responses
  def as_json(options = {})
    super(options.merge(except: [:created_at, :updated_at]))
  end
end
