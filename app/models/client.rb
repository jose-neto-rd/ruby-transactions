class Client < ApplicationRecord
  has_many :transactions, dependent: :destroy

  validates :limit, presence: true, numericality: { only_integer: true }
  validates :balance, presence: true, numericality: { only_integer: true }

  def sufficient_balance?(value)
    (balance - value.to_i) >= -limit
  end

  def credit(value)
    self.balance += value.to_i
  end

  def debit(value)
    unless sufficient_balance?(value)
      raise ArgumentError, "Value surpass limit: #{limit}"
    end
    self.balance -= value.to_i
  end
end
