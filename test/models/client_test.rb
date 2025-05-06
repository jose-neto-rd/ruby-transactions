require "test_helper"

class ClientTest < ActiveSupport::TestCase
  test "#new > when params are right client is valid" do
    client = Client.new(limit: 0, balance: 0)

    assert client.valid?
  end

  test "#new > when limit is nil client is invalid" do
    client = Client.new(limit: nil, balance: 0)

    assert_not client.valid?
  end

  test "#new > when balance is nil client is invalid" do
    client = Client.new(limit: 1000, balance: nil)

    assert_not client.valid?
  end

  test "#sufficient_balance? > when value is not higher than client limit" do
    client = Client.new(limit: 1000, balance: 0)

    assert client.sufficient_balance?(1000)
  end

  test "#sufficient_balance? > when value is higher than client limit" do
    client = Client.new(limit: 1000, balance: 0)

    assert_not client.sufficient_balance?(1001)
  end

  test "#credit > credit the client balance right" do
    value = 1000
    expected = 2000
    client = Client.new(limit: 1000, balance: 1000)

    client.credit(value)

    assert_equal expected, client.balance
  end

  test "#credit > credit the client balance right when pass string valid value" do
    value = "1000"
    expected = 2000
    client = Client.new(limit: 1000, balance: 1000)

    client.credit(value)

    assert_equal expected, client.balance
  end

  test "#debit > debit the client balance right" do
    value = 1000
    expected = 0
    client = Client.new(limit: 1000, balance: 1000)

    client.debit(value)

    assert_equal expected, client.balance
  end

  test "#debit > debit the client balance right when pass string valid value" do
    value = "1000"
    expected = 0
    client = Client.new(limit: 1000, balance: 1000)

    client.debit(value)

    assert_equal expected, client.balance
  end

  test "#debit > debit is blocked when value is higher than limit" do
    value = 10000
    expectedBalance = 1000
    expectedException = "Value surpass limit: 1000"
    client = Client.new(limit: 1000, balance: 1000)

    exception = assert_raises(ArgumentError) do
      client.debit(value)
    end

    assert_equal expectedException, exception.message
    assert_equal expectedBalance, client.balance
  end
end
