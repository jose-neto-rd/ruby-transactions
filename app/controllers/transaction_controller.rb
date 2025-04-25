class TransactionController < ActionController::API
  def index
    client = Client.find_by(id: params[:id])
    return render_not_found unless client

    render json: client.transactions
  rescue ActiveRecord::RecordInvalid => e
    render_unprocessable_entity(e.record.errors)
  end

  def create
    client = Client.find_by(id: params[:id])
    return render_not_found unless client

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

  def render_not_found
    render json: { error: "Client not found!" }, status: :not_found
  end

  def render_unprocessable_entity(errors = nil)
    error_message = if errors.is_a?(Array)
      "Transaction could not be processed: #{errors.join(', ')}!"
    elsif errors&.full_messages&.any?
      "Transaction could not be processed: #{errors.full_messages.join(', ')}!"
    else
      "Transaction could not be processed!"
    end

    render json: { error: error_message }, status: :unprocessable_entity
  end
end
