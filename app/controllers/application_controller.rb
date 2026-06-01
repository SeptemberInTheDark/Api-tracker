class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :render_record_invalid

  private

  def render_not_found(error)
    render json: { errors: [error.message] }, status: :not_found
  end

  def render_record_invalid(error)
    render json: { errors: error.record.errors.full_messages }, status: :unprocessable_entity
  end

  def render_validation_errors(record)
    render json: { errors: record.errors.full_messages }, status: :unprocessable_entity
  end
end
