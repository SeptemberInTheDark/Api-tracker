Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :tasks do
        resources :occurrences, only: [:update], param: :date
        member do
          post "tags/:tag_id", to: "task_tags#create"
          delete "tags/:tag_id", to: "task_tags#destroy"
        end
      end

      resources :tags, except: %i[new edit]
    end
  end

  get "/up", to: proc { [200, { "Content-Type" => "application/json" }, ['{"status":"ok"}']] }
end
