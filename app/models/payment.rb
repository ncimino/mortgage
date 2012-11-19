class Payment < ActiveRecord::Base

  validates_presence_of :amount, :date, :escrow, :interest
  validates_numericality_of :amount, :escrow, :interest
  #validates_format_of :date

  attr_accessible :amount, :date, :escrow, :interest, :fake_id
  attr_accessor :fake_id

  belongs_to :loan

  scope :before, proc { |before_date| where("date < ?", before_date) }
  scope :after, proc { |after_date| where("date >= ?", after_date) }
  scope :between, proc { |after_date, before_date| where("date >= ? AND date < ?", after_date, before_date) }

  default_scope
end
