module Api
  module V1
    class TagsController < ApplicationController
      def index
        render json: { data: Tag.order(:name).map { |tag| TagSerializer.new(tag).as_json } }
      end

      def show
        render json: { data: TagSerializer.new(Tag.find(params[:id])).as_json }
      end

      def create
        tag = Tag.new(tag_params)
        if tag.save
          render json: { data: TagSerializer.new(tag).as_json }, status: :created
        else
          render_validation_errors(tag)
        end
      end

      def update
        tag = Tag.find(params[:id])
        if tag.update(tag_params)
          render json: { data: TagSerializer.new(tag).as_json }
        else
          render_validation_errors(tag)
        end
      end

      def destroy
        tag = Tag.find(params[:id])
        if tag.destroy
          head :no_content
        else
          render_validation_errors(tag)
        end
      end

      private

      def tag_params
        params.require(:tag).permit(:name)
      end
    end
  end
end
