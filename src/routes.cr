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

  latitude = lat_param.to_f
  longitude = lon_param.to_f

  results = CarparkFetcher.fetch(latitude, longitude)
  results.to_json
end