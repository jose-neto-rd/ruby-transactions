require "test_helper"

class ClientsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get clients_url, as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_not_nil json_response
  end

  test "should create client with valid parameters" do
    attributes = { limit: 1000, balance: 0 }

    assert_difference("Client.count") do
      post clients_url, params: attributes, as: :json
    end

    client = JSON.parse(response.body)

    assert_response :created
    assert_equal attributes[:limit], client["limit"]
    assert_equal attributes[:balance], client["balance"]
  end

  test "should not create client with invalid limit parameter" do
    attributes = { limit: "aaaa", balance: 0 }
    expected = "Client not created: Limit is not a number!"

    assert_no_difference("Client.count") do
      post clients_url, params: attributes, as: :json
    end

    fetched_client = JSON.parse(response.body)

    assert_response :unprocessable_entity
    assert_equal expected, fetched_client["error"]
  end

  test "should not create client with invalid balance parameter" do
    attributes = { limit: 0, balance: "aaa" }
    expected = "Client not created: Balance is not a number!"

    assert_no_difference("Client.count") do
      post clients_url, params: attributes, as: :json
    end

    fetched_client = JSON.parse(response.body)

    assert_response :unprocessable_entity
    assert_equal expected, fetched_client["error"]
  end

  test "should show client" do
    client = Client.create!(limit: 1000, balance: 0)

    get "/clients/#{client.id}", as: :json
    assert_response :ok
    fetched_client = JSON.parse(response.body)

    assert_equal client.limit, fetched_client["limit"]
    assert_equal client.balance, fetched_client["balance"]
  end

  test "should show client returns error" do
    expected = "Client not found!"

    get "/clients/invalid-id", as: :json
    fetched_response = JSON.parse(response.body)

    assert_response :not_found
    assert_equal expected, fetched_response["error"]
  end
end
