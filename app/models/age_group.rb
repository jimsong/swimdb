class AgeGroup < ApplicationRecord
  has_many :results
  has_many :relays

  GENDERS = %w(M W).freeze

  def self.find_by_gender_and_text(gender, text)
    text =~ /^(\d+)-/
    start_age = $1.to_i
    AgeGroup.find_by(gender: gender, start_age: start_age)
  end
end
