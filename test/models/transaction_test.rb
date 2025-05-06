require "test_helper"

class TransactionTest < ActiveSupport::TestCase
  setup do
    @client = Client.new(limit: 1000, balance: 0)
  end

  test "#new > when params are right transaction is valid" do
    transaction = @client.transactions.new(value: 1000, transaction_type: "d", description: "test")

    assert transaction.valid?
  end

  test "#new > when limit is nil transaction is invalid" do
    transaction = @client.transactions.new(value: 1000, transaction_type: "aa", description: "test")

    assert_not transaction.valid?
  end

  test "#execute > debit transaction must execute properlly" do
    expected = -100
    transaction = @client.transactions.new(value: 100, transaction_type: "d", description: "test")

    transaction.execute

    assert_equal expected, @client.balance
  end

  test "#execute > credit transaction must execute properlly" do
    expected = 100
    transaction = @client.transactions.new(value: 100, transaction_type: "c", description: "test")

    transaction.execute

    assert_equal expected, @client.balance
  end

  test "#execute > must raise an error when type is not valid" do
    transaction = @client.transactions.new(value: 1000, transaction_type: "aa", description: "test")
    expected = "Inválid transaction type: #{transaction.transaction_type}. Use 'c' or 'd'"

    exception = assert_raises(ArgumentError) do
      transaction.execute
    end

    assert_equal expected, exception.message
  end

  test "#execute > must raise an error when limit is invalid" do
    expected = "Value surpass limit: #{@client.limit}"
    transaction = @client.transactions.new(value: 1001, transaction_type: "d", description: "test")

    exception = assert_raises(ArgumentError) do
      transaction.execute
    end

    assert_equal expected, exception.message
  end
end
