require 'rails_helper'

describe TransactionController, type: :request do
  before do
    Client.destroy_all
    Transaction.destroy_all
  end

  describe '#index' do
    it 'when has transactions to return' do
      client = Client.create!(limit: 1000, balance: 0)
      client.transactions.create!(value: 100, transaction_type: 'd', description: 'test')

      get "/clients/#{client.id}/transactions", as: :json

      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response.size).to eq(1)
    end

    it 'when has no transactions to return' do
      client = Client.create!(limit: 1000, balance: 0)

      get "/clients/#{client.id}/transactions", as: :json

      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response.size).to eq(0)
    end

    it 'when the client does not exist' do
      get '/clients/1/transactions', as: :json

      expect(response).to have_http_status(:not_found)
      json_response = JSON.parse(response.body)
      expect(json_response['error']).to eq('Client not found')
    end
  end

  describe '#create' do
    let(:client) { Client.create!(limit: 1000, balance: 0) }

    it 'when the transaction is created successfully' do
      transaction_attributes = { value: 100, transaction_type: 'd', description: 'test' }

      post "/clients/#{client.id}/transactions", params: transaction_attributes, as: :json

      expect(response).to have_http_status(:created)
      json_response = JSON.parse(response.body)
      expect(json_response['limit']).to eq(1000)
      expect(json_response['balance']).to eq(-100)
    end

    it 'when the client does not exist' do
      transaction_attributes = { value: 100, transaction_type: 'd', description: 'test' }

      post '/clients/0/transactions', params: transaction_attributes, as: :json

      expect(response).to have_http_status(:not_found)
      json_response = JSON.parse(response.body)
      expect(json_response['error']).to eq('Client not found')
    end

    it 'when the transaction fails to execute' do
      allow_any_instance_of(Transaction).to receive(:execute).and_raise(ActiveRecord::RecordInvalid.new(Transaction.new))

      transaction_attributes = { value: 100, transaction_type: 'd', description: 'test' }

      post "/clients/#{client.id}/transactions", params: transaction_attributes, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      json_response = JSON.parse(response.body)
      expect(json_response['error']).to eq('Transaction could not be processed')
    end
  end
end
