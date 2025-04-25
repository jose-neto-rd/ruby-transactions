class Transaction < ApplicationRecord
  belongs_to :client

  validates :value, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :transaction_type, presence: true, inclusion: { in: %w[c d] }
  validates :description, presence: true, length: { in: 1..10 }

  def execute
    value = self.value.to_i
    case transaction_type.to_s
    when "c"
      client.credit(value)
    when "d"
      client.debit(value)
    else
      raise ArgumentError, "Inválid transaction type: #{transaction_type}. Use 'c' or 'd'"
    end
  end
end
