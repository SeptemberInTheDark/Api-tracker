module Api
  module V1
    class TasksController < ApplicationController
      MAX_WINDOW_DAYS = 366

      def index
        window = date_window
        return if performed?

        occurrences = Recurrence::OccurrenceQuery.new(
          Task.includes(:tags, :recurrence_rule, :occurrence_overrides),
          from: window.first,
          to: window.last,
          statuses: status_filter
        ).call

        render json: {
          data: occurrences.map { |occurrence| TaskOccurrenceSerializer.new(occurrence).as_json },
          meta: { from: window.first.iso8601, to: window.last.iso8601, count: occurrences.size }
        }
      end

      def show
        render json: { data: TaskSerializer.new(Task.includes(:tags, :recurrence_rule).find(params[:id])).as_json }
      end

      def create
        task = Task.new(task_params)
        if task.save
          render json: { data: TaskSerializer.new(task).as_json }, status: :created
        else
          render_validation_errors(task)
        end
      end

      def update
        task = Task.find(params[:id])
        if task.update(task_params)
          render json: { data: TaskSerializer.new(task).as_json }
        else
          render_validation_errors(task)
        end
      end

      def destroy
        Task.find(params[:id]).destroy!
        head :no_content
      end

      private

      def date_window
        from = parse_date(params[:from]) || Time.zone.today
        to = parse_date(params[:to]) || from + 30.days
        raise ArgumentError, "to must be on or after from" if to < from
        raise ArgumentError, "date window cannot exceed #{MAX_WINDOW_DAYS} days" if (to - from).to_i > MAX_WINDOW_DAYS

        from..to
      rescue ArgumentError => error
        render json: { errors: [error.message] }, status: :unprocessable_entity
      end

      def parse_date(value)
        return if value.blank?

        Date.iso8601(value)
      end

      def status_filter
        Array(params[:status]).presence
      end

      def task_params
        params.require(:task).permit(
          :title,
          :description,
          :due_date,
          :status,
          tag_ids: [],
          recurrence_rule_attributes: [
            :id,
            :recurrence_type,
            :interval,
            :day_of_month,
            :starts_on,
            :ends_on,
            :parity,
            :_destroy,
            { specific_dates: [] }
          ]
        )
      end
    end
  end
end
