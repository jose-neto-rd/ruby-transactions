require "test_helper"

class ClientsControllerTest < ActionDispatch::IntegrationTest
  setup do
    Client.destroy_all
  end

  test "#index > when has clients to return" do
    attributes = { limit: 1000, balance: 0 }
    Client.create!(attributes)

    get clients_url, as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal 1, json_response.size
  end

  test "#index > when has no clients to return" do
    get clients_url, as: :json
    assert_response :success
    assert_empty JSON.parse(response.body)
  end

  test "#create > when create client successfully" do
    attributes = { limit: 1000, balance: 0 }

    post clients_url, params: attributes, as: :json

    json_response = JSON.parse(response.body)

    assert_response :created
    assert_equal attributes[:limit], json_response["limit"]
    assert_equal attributes[:balance], json_response["balance"]
  end

  test "#create > when create client persist properly" do
    attributes = { limit: 1000, balance: 0 }

    assert_difference("Client.count") do
      post clients_url, params: attributes, as: :json
    end
  end

  test "#create > fail when create client because limit is invalid" do
    attributes = { limit: "aaaa", balance: 0 }
    expected = "Client not created: Limit is not a number"

    assert_no_difference("Client.count") do
      post clients_url, params: attributes, as: :json
    end

    json_response = JSON.parse(response.body)

    assert_response :unprocessable_entity
    assert_equal expected, json_response["error"]
  end

  test "#create > fail when create client because balance is invalid" do
    attributes = { limit: 0, balance: "aaa" }
    expected = "Client not created: Balance is not a number"

    assert_no_difference("Client.count") do
      post clients_url, params: attributes, as: :json
    end

    json_response = JSON.parse(response.body)

    assert_response :unprocessable_entity
    assert_equal expected, json_response["error"]
  end

  test "#create > fail when create client because limit and balance is invalid" do
    attributes = { limit: "aaa", balance: "aaa" }
    expected = "Client not created: Limit is not a number, Balance is not a number"

    assert_no_difference("Client.count") do
      post clients_url, params: attributes, as: :json
    end

    json_response = JSON.parse(response.body)

    assert_response :unprocessable_entity
    assert_equal expected, json_response["error"]
  end

  test "#create > fail when create client because client.save! fails" do
    attributes = { limit: 1000, balance: 0 }
    expected = "Client not created"

    Client.define_method(:save!) do
      raise ActiveRecord::RecordInvalid.new(self)
    end

    post clients_url, params: attributes, as: :json

    json_response = JSON.parse(response.body)

    assert_response :unprocessable_entity
    assert_equal expected, json_response["error"]
  ensure
    Client.remove_method(:save!)
  end

  test "#create > fail to persist when create client because client.save! fails" do
    attributes = { limit: 1000, balance: 0 }

    Client.define_method(:save!) do
      raise ActiveRecord::RecordInvalid.new(self)
    end


    assert_no_difference("Client.count") do
      post clients_url, params: attributes, as: :json
    end
  ensure
    Client.remove_method(:save!)
  end

  test "#show > return a client properly when he exists" do
    client = Client.create!(limit: 1000, balance: 0)

    get "/clients/#{client.id}", as: :json
    assert_response :ok
    json_response = JSON.parse(response.body)

    assert_equal client.limit, json_response["limit"]
    assert_equal client.balance, json_response["balance"]
  end

  test "#show > return an error when client dont exists" do
    expected = "Client not found"

    get "/clients/invalid-id", as: :json
    json_response = JSON.parse(response.body)

    assert_response :not_found
    assert_equal expected, json_response["error"]
  end
end
