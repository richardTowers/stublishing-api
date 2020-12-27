require "sinatra"
require "pstore"
require "json"

set :port, ENV.fetch("PORT", 9999)

db = PStore.new("stublishing-api.pstore", true)
db.transaction do
  db["linkables"] = []
  db["content"] = {}
end

get "/v2/linkables" do
  result =
    db.transaction true do
      db["linkables"].select do |linkable|
        linkable["document_type"] == params["document_type"]
      end
    end
  result.to_json
end

put "/v2/content/:content_id" do
  request.body.rewind
  data = JSON.parse request.body.read

  db.transaction do
    db["content"][params["content_id"]] = data
  end

  data.to_json
end

get "/v2/content/:content_id" do
  db.transaction true do
    db["content"][params["content_id"]]
  end
end

