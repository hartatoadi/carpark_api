require "sqlite3"
require "json"
require "../utils/haversine"

DB_PATH = "./db/database.sqlite"

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

      db.query_all(
        sql,
        [] of DB::Any, # <= inilah *args_
        as: {
          carpark_number: String,
          address: String,
          latitude: Float64,
          longitude: Float64,
          total_lots: Int32?,
          available_lots: Int32?
        }
      ) do |row|
        distance = Haversine.calculate(latitude, longitude, row[:latitude], row[:longitude])
        results << {
          "carpark_number"   => JSON::Any.new(row[:carpark_number]),
          "address"          => JSON::Any.new(row[:address]),
          "latitude"         => JSON::Any.new(row[:latitude]),
          "longitude"        => JSON::Any.new(row[:longitude]),
          "total_lots"       => JSON::Any.new(row[:total_lots]?),
          "available_lots"   => JSON::Any.new(row[:available_lots]?),
          "distance_km"      => JSON::Any.new(distance.round(3))
        }
      end
    end

    results.sort_by! { |r| r["distance_km"].as_f }
    results
  end
end