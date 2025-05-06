require 'rails_helper'

describe Transaction, type: :model do
  let(:client) { Client.new(limit: 1000, balance: 0) }

  describe '#new' do
    it 'is valid when params are correct' do
      transaction = client.transactions.new(value: 1000, transaction_type: 'd', description: 'test')

      expect(transaction).to be_valid
    end

    it 'is invalid when transaction type is invalid' do
      transaction = client.transactions.new(value: 1000, transaction_type: 'aa', description: 'test')

      expect(transaction).not_to be_valid
    end
  end

  describe '#execute' do
    it 'executes debit transaction properly' do
      expected = -100
      transaction = client.transactions.new(value: 100, transaction_type: 'd', description: 'test')

      transaction.execute

      expect(client.balance).to eq(expected)
    end

    it 'executes credit transaction properly' do
      expected = 100
      transaction = client.transactions.new(value: 100, transaction_type: 'c', description: 'test')

      transaction.execute

      expect(client.balance).to eq(expected)
    end

    it 'raises an error when transaction type is invalid' do
      transaction = client.transactions.new(value: 1000, transaction_type: 'aa', description: 'test')
      expected_message = "Inválid transaction type: #{transaction.transaction_type}. Use 'c' or 'd'"

      expect { transaction.execute }.to raise_error(ArgumentError, expected_message)
    end

    it 'raises an error when value surpasses limit' do
      transaction = client.transactions.new(value: 1001, transaction_type: 'd', description: 'test')
      expected_message = "Value surpass limit: #{client.limit}"

      expect { transaction.execute }.to raise_error(ArgumentError, expected_message)
    end
  end
end
