module Api
  module V1
    class TaskTagsController < ApplicationController
      def create
        task = Task.find(params[:id])
        tag = Tag.find(params[:tag_id])
        task.tags << tag unless task.tags.exists?(tag.id)

        render json: { data: TaskSerializer.new(task.reload).as_json }, status: :created
      end

      def destroy
        task = Task.find(params[:id])
        task.tags.destroy(Tag.find(params[:tag_id]))

        render json: { data: TaskSerializer.new(task.reload).as_json }
      end
    end
  end
end
