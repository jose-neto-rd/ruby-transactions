class ClientsController < ActionController::API
  def index
    render json: Client.all
  end

  def create
    client = Client.new(create_params)

    if client.invalid?
      return render_unprocessable_entity(client.errors)
    end

    ActiveRecord::Base.transaction do
      client.save!
    end

    render json: client, status: :created
  rescue ActiveRecord::RecordInvalid => e
    render_unprocessable_entity(e.record.errors)
  end

  def show
    client = Client.find(params[:id])
    render json: {
      limit: client.limit,
      balance: client.balance
    }, status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Client not found!" }, status: :not_found
  end

  private

  def create_params
    params.permit(:limit, :balance)
  end

  def render_unprocessable_entity(errors = nil)
    error_message = if errors&.full_messages&.any?
      "Client not created: #{errors.full_messages.join(', ')}!"
    else
      "Client not created!"
    end

    render json: { error: error_message }, status: :unprocessable_entity
  end
end
