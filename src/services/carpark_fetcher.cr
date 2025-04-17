require "sqlite3"
require "json"
require "../utils/haversine"

DB_PATH = "./db/database.sqlite"

alias CarparkRow = NamedTuple(
  carpark_number: String,
  address: String,
  latitude: Float64,
  longitude: Float64,
  total_lots: Int32?,
  available_lots: Int32?
)

module CarparkFetcher
  def self.fetch(latitude : Float64, longitude : Float64)
    results = [] of Hash(String, JSON::Any)

    DB.open "sqlite3://#{DB_PATH}" do |db|
      sql = <<-SQL
        SELECT
          i.carpark_number,
          i.address,
          i.latitude,
          i.longitude,
          a.total_lots,
          a.available_lots
        FROM carpark_infos i
        LEFT JOIN carpark_availabilities a ON i.carpark_number = a.carpark_number
      SQL

      db.query_all(sql) do |row|
        carpark_number = row.read(String)
        address = row.read(String)
        latitude = row.read(Float64)
        longitude = row.read(Float64)
        total_lots = row.read(Int32?)
        available_lots = row.read(Int32?)

        carpark_row = {
          carpark_number: carpark_number,
          address: address,
          latitude: latitude,
          longitude: longitude,
          total_lots: total_lots,
          available_lots: available_lots
        }

        distance = Haversine.calculate(latitude, longitude, carpark_row[:latitude], carpark_row[:longitude])

        results << {
          "carpark_number" => JSON::Any.new(carpark_row[:carpark_number]),
          "address" => JSON::Any.new(carpark_row[:address]),
          "latitude" => JSON::Any.new(carpark_row[:latitude]),
          "longitude" => JSON::Any.new(carpark_row[:longitude]),
          "total_lots" => JSON::Any.new(carpark_row[:total_lots]),
          "available_lots" => JSON::Any.new(carpark_row[:available_lots]),
          "distance_km" => JSON::Any.new(distance.round(3))
        }
      end

    end

    results.sort_by! { |r| r["distance_km"].as_f }
    results
  end
end
