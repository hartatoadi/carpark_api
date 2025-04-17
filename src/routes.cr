require "kemal"
require "./services/carpark_fetcher"
require "json"

get "/carparks" do |env|
  lat_param = env.params.query["latitude"]?
  lon_param = env.params.query["longitude"]?

  unless lat_param && lon_param
    env.response.status_code = 400
    next { error: "Missing latitude or longitude" }.to_json
  end

  page = (env.params.query["page"]? || "1").to_i
  per_page = (env.params.query["per_page"]? || "10").to_i
  offset = (page - 1) * per_page

  latitude = lat_param.to_f
  longitude = lon_param.to_f

  results = CarparkFetcher.fetch(latitude, longitude)
  paginated = results[offset, per_page] || [] of Hash(String, JSON::Any)

  paginated.to_json
end