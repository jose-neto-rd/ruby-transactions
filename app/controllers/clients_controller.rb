class ClientsController < ApplicationController
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
    client = find_client
    return unless client

    render json: {
      limit: client.limit,
      balance: client.balance
    }, status: :ok
  rescue ActiveRecord::RecordNotFound
    render_client_not_found
  end

  private

  def create_params
    params.permit(:limit, :balance)
  end

  def render_unprocessable_entity(errors = nil)
    render_validation_errors("Client not created", errors)
  end
end
