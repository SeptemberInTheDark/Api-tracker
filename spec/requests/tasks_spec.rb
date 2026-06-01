require "rails_helper"
require "support/json_helpers"

RSpec.describe "Tasks API", type: :request do
  before do
    Tag::REQUIRED_NAMES.each { |name| Tag.create!(name: name, locked: true) }
  end

  it "creates, reads, updates, filters, and deletes a task" do
    post "/api/v1/tasks", params: {
      task: {
        title: "Связаться с клиентом",
        description: "Уточнить дату приема",
        due_date: "2026-06-01",
        status: "pending",
        tag_ids: [Tag.find_by!(name: "звонок").id]
      }
    }

    expect(response).to have_http_status(:created)
    task_id = json.fetch("data").fetch("id")

    get "/api/v1/tasks", params: { from: "2026-06-01", to: "2026-06-01", status: ["pending"] }
    expect(json.fetch("data").pluck("task_id")).to contain_exactly(task_id)
    expect(json.fetch("data").first.fetch("tags").first.fetch("name")).to eq("звонок")

    patch "/api/v1/tasks/#{task_id}", params: { task: { status: "done" } }
    expect(response).to have_http_status(:ok)
    expect(json.fetch("data").fetch("status")).to eq("done")

    delete "/api/v1/tasks/#{task_id}"
    expect(response).to have_http_status(:no_content)
  end

  it "expands recurring tasks for a finite window and stores independent occurrence status" do
    post "/api/v1/tasks", params: {
      task: {
        title: "Ежедневный обход",
        description: "Проверить состояние пациентов",
        due_date: "2026-06-01",
        recurrence_rule_attributes: {
          recurrence_type: "daily",
          interval: 1,
          starts_on: "2026-06-01"
        }
      }
    }

    task_id = json.fetch("data").fetch("id")

    patch "/api/v1/tasks/#{task_id}/occurrences/2026-06-02", params: {
      occurrence: { status: "done" }
    }
    expect(response).to have_http_status(:ok)

    get "/api/v1/tasks", params: { from: "2026-06-01", to: "2026-06-03" }
    statuses = json.fetch("data").to_h { |item| [item.fetch("occurrence_date"), item.fetch("status")] }

    expect(statuses).to eq(
      "2026-06-01" => "pending",
      "2026-06-02" => "done",
      "2026-06-03" => "pending"
    )
    expect(OccurrenceOverride.count).to eq(1)
  end

  it "attaches and removes tags through task member endpoints" do
    task = Task.create!(title: "Отчет", description: "Подготовить отчет", due_date: "2026-06-01")
    tag = Tag.find_by!(name: "отчетность")

    post "/api/v1/tasks/#{task.id}/tags/#{tag.id}"
    expect(response).to have_http_status(:created)
    expect(json.fetch("data").fetch("tags").pluck("name")).to include("отчетность")

    delete "/api/v1/tasks/#{task.id}/tags/#{tag.id}"
    expect(response).to have_http_status(:ok)
    expect(json.fetch("data").fetch("tags")).to be_empty
  end
end
