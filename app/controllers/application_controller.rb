class ApplicationController < ActionController::API
  private

  def find_resource(klass, id, not_found_message = nil)
    resource = klass.find_by(id: id)
    return resource if resource

    not_found_message ||= "#{klass.model_name.human} not found"
    render_error(not_found_message, :not_found)
    nil
  end

  def render_error(message, status = :unprocessable_entity)
    render json: { error: message }, status: status
  end

  def render_client_not_found
    render_error("Client not found", :not_found)
  end

  def render_validation_errors(base_message = "Validation failed", errors = nil)
    full_message = if errors.is_a?(Array)
      "#{base_message}: #{errors.join(', ')}"
    elsif errors&.full_messages&.any?
      "#{base_message}: #{errors.full_messages.join(', ')}"
    else
      base_message
    end

    render_error(full_message, :unprocessable_entity)
  end

  def find_client
    find_resource(Client, params[:id])
  end
end
