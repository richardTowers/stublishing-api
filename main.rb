require "sinatra"
require "pstore"
require "json"

set :port, ENV.fetch("PORT", 9999)

db = PStore.new("stublishing-api.pstore", true)
db.transaction do
  db["linkables"] ||= []
  db["content"]   ||= {}
  db["editions"]  ||= []
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

post "/v2/content/:content_id/publish" do
  # TODO - what should this resource actually do?
  # This seems to work, but we should probably be doing something with the request body...
  response = db.transaction true do
               db["content"][params["content_id"]]
             end
  response.to_json
end

get "/v2/editions" do
  editions = db.transaction true do
    # TODO support filtering based on document_types and states,
    # mapping based on fields
    db["editions"]
  end
  response = {
    "results" => editions,
    "links" => []
  }

  response.to_json
end

get "/" do
  response = db.transaction true do
              db.roots.map do |root|
                [root, db[root]]
              end.to_h
             end
  response.to_json
end
