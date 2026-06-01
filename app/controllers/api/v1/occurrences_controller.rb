module Api
  module V1
    class OccurrencesController < ApplicationController
      def update
        task = Task.find(params[:task_id])
        date = Date.iso8601(params[:date])
        override = task.occurrence_overrides.find_or_initialize_by(occurrence_date: date)

        if override.update(occurrence_params)
          occurrence = Recurrence::TaskOccurrence.from_task(task.reload, date, override)
          render json: { data: TaskOccurrenceSerializer.new(occurrence).as_json }
        else
          render_validation_errors(override)
        end
      rescue Date::Error
        render json: { errors: ["date must be ISO 8601"] }, status: :unprocessable_entity
      end

      private

      def occurrence_params
        params.require(:occurrence).permit(:status, :title, :description, :due_time, :cancelled)
      end
    end
  end
end
