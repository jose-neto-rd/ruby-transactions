require "test_helper"

class TransactionControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    client_atributes = { limit: 1000, balance: 0 }
    transaction_atributes = { value: 100, transaction_type: "d", description: "test" }
    client = Client.create!(client_atributes)
    client.transactions.create!(transaction_atributes)

    get "/clients/#{client.id}/transactions", as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_not_nil json_response
  end

  test "should noy get index" do
    expected = "Client not found!"

    get "/clients/0/transactions", as: :json
    fetched_response = JSON.parse(response.body)

    assert_response :not_found
    assert_equal expected, fetched_response["error"]
  end

  test "should create transaction" do
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

  test "should dint create transaction by invalid client" do
    expected = "Client not found!"
    transaction_atributes = { value: 10000, transaction_type: "d", description: "test" }

    post "/clients/0/transactions", params: transaction_atributes, as: :json
    assert_response :not_found

    json_response = JSON.parse(response.body)
    assert_not_nil json_response
    assert_equal expected, json_response["error"]
  end

  test "should dint create transaction by error on client.save!" do
    expected = "Transaction could not be processed!"
    transaction_atributes = { value: 100, transaction_type: "d", description: "test" }
    client_atributes = { limit: 1000, balance: 0 }
    client = Client.create!(client_atributes)

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
      # Remove o mock após o teste
      Client.remove_method(:save!)
    end
  end

  test "should dint create transaction by error on transaction.save!" do
    expected = "Transaction could not be processed!"
    transaction_atributes = { value: 100, transaction_type: "d", description: "test" }
    client_atributes = { limit: 1000, balance: 0 }
    client = Client.create!(client_atributes)

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
      # Remove o mock após o teste
      Transaction.remove_method(:save!)
    end
  end

  test "should dint create transaction by invalid value" do
    expected = "Transaction could not be processed: Value surpass limit: 1000!"
    client_atributes = { limit: 1000, balance: 0 }
    transaction_atributes = { value: 10000, transaction_type: "d", description: "test" }
    client = Client.create!(client_atributes)

    post "/clients/#{client.id}/transactions", params: transaction_atributes, as: :json
    assert_response :unprocessable_entity

    json_response = JSON.parse(response.body)
    assert_not_nil json_response
    assert_equal expected, json_response["error"]
  end

  test "should dint create transaction by invalid transaction_type" do
    expected = "Transaction could not be processed: Transaction type is not included in the list!"
    client_atributes = { limit: 1000, balance: 0 }
    transaction_atributes = { value: 100, transaction_type: "cc", description: "test" }
    client = Client.create!(client_atributes)

    post "/clients/#{client.id}/transactions", params: transaction_atributes, as: :json
    assert_response :unprocessable_entity

    json_response = JSON.parse(response.body)
    assert_not_nil json_response
    assert_equal expected, json_response["error"]
  end
end
