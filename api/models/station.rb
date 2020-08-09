# frozen_string_literal: true

class Station
  include Mongoid::Document

  field :name, type: String
  field :trains, type: Array, default: []

  validates :name, presence: true

  index({ name: 1 }, { unique: true })

  def accept(train)
    push(trains: train) unless trains.include?(train)
  end

  def remove(train)
    pull(trains: train)
  end
end
