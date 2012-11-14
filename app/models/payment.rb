class Payment < ActiveRecord::Base

  validates_presence_of :amount, :date, :escrow, :interest
  validates_numericality_of :amount, :escrow, :interest
  #validates_format_of :date

  attr_accessible :amount, :date, :escrow, :interest

  belongs_to :loan
end
