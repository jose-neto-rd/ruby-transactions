require "test_helper"

class ClientTest < ActiveSupport::TestCase
  test "must be valid" do
    client = Client.new(limit: 0, balance: 0)

    assert client.valid?
  end

  test "must be invalid when limit is nil" do
    client = Client.new(limit: nil, balance: 0)

    assert_not client.valid?
  end

  test "must be invalid when balance is nil" do
    client = Client.new(limit: 1000, balance: nil)

    assert_not client.valid?
  end

  test "must be define it has sufficient balance" do
    client = Client.new(limit: 1000, balance: 0)

    assert client.sufficient_balance?(1000)
  end

  test "must be define it doesnt have sufficient balance" do
    client = Client.new(limit: 1000, balance: 0)

    assert_not client.sufficient_balance?(1001)
  end

  test "must credit right" do
    value = 1000
    expected = 2000
    client = Client.new(limit: 1000, balance: 1000)

    client.credit(value)

    assert_equal expected, client.balance
  end

  test "must credit right when pass string valid value" do
    value = "1000"
    expected = 2000
    client = Client.new(limit: 1000, balance: 1000)

    client.credit(value)

    assert_equal expected, client.balance
  end

  test "must debit right" do
    value = 1000
    expected = 0
    client = Client.new(limit: 1000, balance: 1000)

    client.debit(value)

    assert_equal expected, client.balance
  end

  test "must debit right when pass string" do
    value = "1000"
    expected = 0
    client = Client.new(limit: 1000, balance: 1000)

    client.debit(value)

    assert_equal expected, client.balance
  end

  test "must dont debit right when balance limit is enought" do
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
