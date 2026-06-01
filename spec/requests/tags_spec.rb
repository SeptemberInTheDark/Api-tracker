require "rails_helper"
require "support/json_helpers"

RSpec.describe "Tags API", type: :request do
  it "prevents required tags from being changed or deleted" do
    tag = Tag.create!(name: "операции", locked: true)

    patch "/api/v1/tags/#{tag.id}", params: { tag: { name: "операционные" } }
    expect(response).to have_http_status(422)

    delete "/api/v1/tags/#{tag.id}"
    expect(response).to have_http_status(422)
    expect(Tag.exists?(tag.id)).to be(true)
  end

  it "allows custom tag lifecycle" do
    post "/api/v1/tags", params: { tag: { name: "инвентаризация" } }
    expect(response).to have_http_status(:created)

    tag_id = json.fetch("data").fetch("id")
    patch "/api/v1/tags/#{tag_id}", params: { tag: { name: "склад" } }
    expect(response).to have_http_status(:ok)
    expect(json.fetch("data").fetch("name")).to eq("склад")

    delete "/api/v1/tags/#{tag_id}"
    expect(response).to have_http_status(:no_content)
  end
end
