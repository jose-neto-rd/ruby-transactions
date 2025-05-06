class TransactionController < ApplicationController
  def index
    client = find_client
    return unless client

    render json: client.transactions
  rescue ActiveRecord::RecordInvalid => e
    render_unprocessable_entity(e.record.errors)
  end

  def create
    client = find_client
    return unless client

    transaction = client.transactions.new(transaction_params)
    if transaction.invalid?
      return render_unprocessable_entity(transaction.errors)
    end

    begin
      transaction.execute

      ActiveRecord::Base.transaction do
        transaction.save!
        client.save!
    end

    render json: { limit: client.limit, balance: client.balance }, status: :created
    rescue ArgumentError => e
      render_unprocessable_entity([ e.message ])
    rescue ActiveRecord::RecordInvalid => e
      render_unprocessable_entity(e.record.errors)
    end
  end

  private

  def transaction_params
    params.permit(:value, :transaction_type, :description)
  end

  def render_unprocessable_entity(errors = nil)
    render_validation_errors("Transaction could not be processed", errors)
  end
end
