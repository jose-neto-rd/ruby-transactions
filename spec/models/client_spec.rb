require 'rails_helper'

describe Client, type: :model do
  describe '#new' do
    it 'is valid when params are correct' do
      client = Client.new(limit: 0, balance: 0)

      expect(client).to be_valid
    end

    it 'is invalid when limit is nil' do
      client = Client.new(limit: nil, balance: 0)

      expect(client).not_to be_valid
    end

    it 'is invalid when balance is nil' do
      client = Client.new(limit: 1000, balance: nil)

      expect(client).not_to be_valid
    end
  end

  describe '#sufficient_balance?' do
    it 'returns true when value is not higher than client limit' do
      client = Client.new(limit: 1000, balance: 0)

      expect(client.sufficient_balance?(1000)).to be true
    end

    it 'returns false when value is higher than client limit' do
      client = Client.new(limit: 1000, balance: 0)

      expect(client.sufficient_balance?(1001)).to be false
    end
  end

  describe '#credit' do
    it 'credits the client balance correctly' do
      client = Client.new(limit: 1000, balance: 1000)

      client.credit(1000)

      expect(client.balance).to eq(2000)
    end

    it 'credits the client balance correctly when passing a valid string value' do
      client = Client.new(limit: 1000, balance: 1000)

      client.credit('1000')

      expect(client.balance).to eq(2000)
    end
  end

  describe '#debit' do
    it 'debits the client balance correctly' do
      client = Client.new(limit: 1000, balance: 1000)

      client.debit(1000)

      expect(client.balance).to eq(0)
    end

    it 'debits the client balance correctly when passing a valid string value' do
      client = Client.new(limit: 1000, balance: 1000)

      client.debit('1000')

      expect(client.balance).to eq(0)
    end

    it 'raises an error when value is higher than limit' do
      client = Client.new(limit: 1000, balance: 1000)

      expect { client.debit(10_000) }.to raise_error(ArgumentError, 'Value surpass limit: 1000')
      expect(client.balance).to eq(1000)
    end
  end
end
