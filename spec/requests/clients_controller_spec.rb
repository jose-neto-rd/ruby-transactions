require 'rails_helper'

describe ClientsController, type: :request do
  before do
    Client.destroy_all
  end

  describe '#index' do
    it 'when has clients to return' do
      attributes = { limit: 1000, balance: 0 }
      Client.create!(attributes)

      get clients_url, as: :json
      expect(response).to have_http_status(:success)

      json_response = JSON.parse(response.body)
      expect(json_response.size).to eq(1)
    end

    it 'when has no clients to return' do
      get clients_url, as: :json
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)).to be_empty
    end
  end

  describe '#create' do
    it 'when create client successfully' do
      attributes = { limit: 1000, balance: 0 }

      post clients_url, params: attributes, as: :json

      json_response = JSON.parse(response.body)

      expect(response).to have_http_status(:created)
      expect(json_response['limit']).to eq(attributes[:limit])
      expect(json_response['balance']).to eq(attributes[:balance])
    end

    it 'when create client persist properly' do
      attributes = { limit: 1000, balance: 0 }

      expect {
        post clients_url, params: attributes, as: :json
      }.to change(Client, :count).by(1)
    end

    it 'fail when create client because limit is invalid' do
      attributes = { limit: 'aaaa', balance: 0 }
      expected = 'Client not created: Limit is not a number'

      expect {
        post clients_url, params: attributes, as: :json
      }.not_to change(Client, :count)

      json_response = JSON.parse(response.body)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json_response['error']).to eq(expected)
    end

    it 'fail when create client because balance is invalid' do
      attributes = { limit: 0, balance: 'aaa' }
      expected = 'Client not created: Balance is not a number'

      expect {
        post clients_url, params: attributes, as: :json
      }.not_to change(Client, :count)

      json_response = JSON.parse(response.body)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json_response['error']).to eq(expected)
    end

    it 'fail when create client because limit and balance is invalid' do
      attributes = { limit: 'aaa', balance: 'aaa' }
      expected = 'Client not created: Limit is not a number, Balance is not a number'

      expect {
        post clients_url, params: attributes, as: :json
      }.not_to change(Client, :count)

      json_response = JSON.parse(response.body)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json_response['error']).to eq(expected)
    end

    it 'fail when create client because client.save! fails' do
      attributes = { limit: 1000, balance: 0 }
      expected = 'Client not created'

      allow_any_instance_of(Client).to receive(:save!).and_raise(ActiveRecord::RecordInvalid.new(Client.new))

      post clients_url, params: attributes, as: :json

      json_response = JSON.parse(response.body)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json_response['error']).to eq(expected)
    end

    it 'fail to persist when create client because client.save! fails' do
      attributes = { limit: 1000, balance: 0 }

      allow_any_instance_of(Client).to receive(:save!).and_raise(ActiveRecord::RecordInvalid.new(Client.new))

      expect {
        post clients_url, params: attributes, as: :json
      }.not_to change(Client, :count)
    end
  end

  describe '#show' do
    it 'return a client properly when he exists' do
      client = Client.create!(limit: 1000, balance: 0)

      get "/clients/#{client.id}", as: :json
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)

      expect(json_response['limit']).to eq(client.limit)
      expect(json_response['balance']).to eq(client.balance)
    end

    it 'return an error when client dont exists' do
      expected = 'Client not found'

      get '/clients/invalid-id', as: :json
      json_response = JSON.parse(response.body)

      expect(response).to have_http_status(:not_found)
      expect(json_response['error']).to eq(expected)
    end
  end
end
