class Appliance < ApplicationRecord
  belongs_to :use
  has_many :sources

  mount_uploader :photo, PhotoUploader

  validates :name, presence: true, uniqueness: true
  validates :power_factor, numericality: {greater_than_or_equal_to: 0, less_than_or_equal_to: 1}, allow_nil: true
  validates :starting_coefficient, numericality: {greater_than_or_equal_to: 1}, allow_nil: true
  validates :current_type, presence: true
  validates :voltage_min, numericality: {greater_than_or_equal_to: 0}, allow_nil: true
  validates :voltage_max, numericality: {greater_than_or_equal_to: 0}, allow_nil: true

  TYPES = ["AC", "DC"]
  RATES = {
    "1" => "10",
    "0.9" => "9",
    "0.8" => "8",
    "0.7" => "7",
    "0.6" => "6",
    "0.5" => "5",
    "0.4" => "4",
    "0.3" => "3",
    "0.2" => "2",
    "0.1" => "1"
  }
  GRADES = ["A+++", "A++", "A+", "A", "B", "C", "D", "E", "F", "G"]
  GRADE_CLASSES = {
    "A+++" => "grade-a-plus-plus-plus",
    "A++" => "grade-a-plus-plus",
    "A+" => "grade-a-plus",
    "A" => "grade-a",
    "B" => "grade-b",
    "C" => "grade-c",
    "D" => "grade-d",
    "E" => "grade-e",
    "F" => "grade-f",
    "G" => "grade-g"
  }

  def apparent_power
    (power / power_factor).round(1) if power and power_factor
  end

  def max_power
    (apparent_power * starting_coefficient).round(1) if apparent_power and starting_coefficient
  end

  (0..23).each do |i|
    define_method("hourly_consumption_#{i}") do
      (method("hourly_rate_#{i}").call.to_f / 10 * apparent_power).round if apparent_power
    end
  end

  def daily_consumption
    result = 0
    (0..23).each { |i| result += method("hourly_consumption_#{i}").call if apparent_power }
    result
  end

  def frequencies
    if frequency_fifty_hz and current_type == "AC"
      frequency_sixty_hz ? "50 Hz or 60 Hz" : "50 Hz"
    elsif frequency_sixty_hz and current_type == "AC"
      "60 Hz"
    else
      "n/a"
    end
  end

  def voltage_range
    if voltage_min
      voltage_max ? "#{voltage_min} V - #{voltage_max} V" : "#{voltage_min} V"
    elsif voltage_max
      "#{voltage_max} V"
    else
      "n/a"
    end
  end

end
