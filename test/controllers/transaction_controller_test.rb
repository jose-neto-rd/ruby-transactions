require "test_helper"

class TransactionControllerTest < ActionDispatch::IntegrationTest
  setup do
    Client.destroy_all
    Transaction.destroy_all
  end

  test "#index > when has transactions to return" do
    client_atributes = { limit: 1000, balance: 0 }
    transaction_atributes = { value: 100, transaction_type: "d", description: "test" }
    client = Client.create!(client_atributes)
    client.transactions.create!(transaction_atributes)

    get "/clients/#{client.id}/transactions", as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal 1, json_response.size
  end

  test "#index > when has no transactions to return" do
    client_atributes = { limit: 1000, balance: 0 }
    client = Client.create!(client_atributes)

    get "/clients/#{client.id}/transactions", as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal 0, json_response.size
  end

  test "#index > whe has id informed not find any client" do
    expected = "Client not found"

    get "/clients/1/transactions", as: :json
    fetched_response = JSON.parse(response.body)

    assert_response :not_found
    assert_equal expected, fetched_response["error"]
  end

  test "#create > when create a transaction it persists successfully" do
    client_atributes = { limit: 1000, balance: 0 }
    transaction_atributes = { value: 100, transaction_type: "d", description: "test" }
    client = Client.create!(client_atributes)
    assert_difference("Transaction.count") do
      post "/clients/#{client.id}/transactions", params: transaction_atributes, as: :json
    end
  end

  test "#create > when create a transaction balance is changed properlly" do
    expectedLimit = 1000
    expectedBalance = -100
    client_atributes = { limit: 1000, balance: 0 }
    transaction_atributes = { value: 100, transaction_type: "d", description: "test" }
    client = Client.create!(client_atributes)

    post "/clients/#{client.id}/transactions", params: transaction_atributes, as: :json
    assert_response :created

    json_response = JSON.parse(response.body)
    assert_not_nil json_response
    assert_equal expectedLimit, json_response["limit"]
    assert_equal expectedBalance, json_response["balance"]
  end

  test "#create > when client does not exists" do
    expected = "Client not found"
    transaction_atributes = { value: 10000, transaction_type: "d", description: "test" }

    post "/clients/0/transactions", params: transaction_atributes, as: :json
    assert_response :not_found

    json_response = JSON.parse(response.body)
    assert_not_nil json_response
    assert_equal expected, json_response["error"]
  end

  test "#create > when transaction.execute fails" do
    expected = "Transaction could not be processed"
    transaction_atributes = { value: 100, transaction_type: "d", description: "test" }
    client_atributes = { limit: 1000, balance: 0 }
    client = Client.create!(client_atributes)

    original_execute = Transaction.instance_method(:execute)

    Transaction.define_method(:execute) do
      raise ActiveRecord::RecordInvalid.new(self)
    end

    post "/clients/#{client.id}/transactions", params: transaction_atributes, as: :json
    assert_response :unprocessable_entity

    json_response = JSON.parse(response.body)
    assert_not_nil json_response
    assert_equal expected, json_response["error"]
  ensure
    Transaction.define_method(:execute, original_execute)
  end

  test "#create > when client.save! fails" do
    expected = "Transaction could not be processed"
    transaction_atributes = { value: 100, transaction_type: "d", description: "test" }
    client_atributes = { limit: 1000, balance: 0 }
    client = Client.create!(client_atributes)

    original_save = Transaction.instance_method(:execute)

    Client.define_method(:save!) do
      raise ActiveRecord::RecordInvalid.new(self)
    end

    begin
    post "/clients/#{client.id}/transactions", params: transaction_atributes, as: :json
    assert_response :unprocessable_entity

    json_response = JSON.parse(response.body)
    assert_not_nil json_response
    assert_equal expected, json_response["error"]
    ensure
      Client.define_method(:execute, original_save)
    end
  end

  test "#create > when transaction.save! fails" do
    expected = "Transaction could not be processed"
    transaction_atributes = { value: 100, transaction_type: "d", description: "test" }
    client_atributes = { limit: 1000, balance: 0 }
    client = Client.create!(client_atributes)

    original_execute = Transaction.instance_method(:execute)

    Transaction.define_method(:save!) do
      raise ActiveRecord::RecordInvalid.new(self)
    end

    begin
    post "/clients/#{client.id}/transactions", params: transaction_atributes, as: :json
    assert_response :unprocessable_entity

    json_response = JSON.parse(response.body)
    assert_not_nil json_response
    assert_equal expected, json_response["error"]
    ensure
      Transaction.define_method(:execute, original_execute)
    end
  end

  test "#create > when execute a transaction fails by invalid value" do
    expected = "Transaction could not be processed: Value surpass limit: 1000"
    client_atributes = { limit: 1000, balance: 0 }
    transaction_atributes = { value: 10000, transaction_type: "d", description: "test" }
    client = Client.create!(client_atributes)

    post "/clients/#{client.id}/transactions", params: transaction_atributes, as: :json
    assert_response :unprocessable_entity

    json_response = JSON.parse(response.body)
    assert_not_nil json_response
    assert_equal expected, json_response["error"]
  end

  test "#create > when execute a transaction by invalid transaction_type" do
    expected = "Transaction could not be processed: Transaction type is not included in the list"
    client_atributes = { limit: 1000, balance: 0 }
    transaction_atributes = { value: 100, transaction_type: "cc", description: "test" }
    client = Client.create!(client_atributes)

    post "/clients/#{client.id}/transactions", params: transaction_atributes, as: :json
    assert_response :unprocessable_entity

    json_response = JSON.parse(response.body)
    assert_not_nil json_response
    assert_equal expected, json_response["error"]
  end

  test "#create > when execute a transaction by invalid description" do
    expected = "Transaction could not be processed: Description can't be blank, Description is too short (minimum is 1 character)"
    client_atributes = { limit: 1000, balance: 0 }
    transaction_atributes = { value: 100, transaction_type: "d", description: nil }
    client = Client.create!(client_atributes)

    post "/clients/#{client.id}/transactions", params: transaction_atributes, as: :json
    assert_response :unprocessable_entity

    json_response = JSON.parse(response.body)
    assert_not_nil json_response
    assert_equal expected, json_response["error"]
  end

  test "#create > when execute a transaction by invalid value, transaction_type and description" do
    expected = "Transaction could not be processed: Value is not a number, Transaction type is not included in the list, Description can't be blank, Description is too short (minimum is 1 character)"
    client_atributes = { limit: 1000, balance: 0 }
    transaction_atributes = { value: "aa", transaction_type: "cc", description: nil }
    client = Client.create!(client_atributes)

    post "/clients/#{client.id}/transactions", params: transaction_atributes, as: :json
    assert_response :unprocessable_entity

    json_response = JSON.parse(response.body)
    assert_not_nil json_response
    assert_equal expected, json_response["error"]
  end
end
