require "http/client"
require "csv"
require "json"
require "sqlite3"
require "./svy21"

module DataLoader
  DB_PATH = "./db/database.sqlite"

  def self.db(&block)
    DB.open "sqlite3://#{DB_PATH}" do |db|
      yield db
    end
  end

  def self.load_static_info
    puts "Loading static carpark info from file..."
    file_path = "./data/HDBCarparkInformation.csv"
    parsed = CSV.parse(File.read(file_path))
    csv = parsed.to_a
    header = csv[0]
    rows = csv[1..]

    indexes = {
      number: header.index("car_park_no").not_nil!,
      address: header.index("address").not_nil!,
      x: header.index("x_coord").not_nil!,
      y: header.index("y_coord").not_nil!,
    }

    db do |db|
      rows.each do |row|
        carpark_number = row[indexes[:number]].to_s
        address = row[indexes[:address]].to_s
        x = row[indexes[:x]].to_f
        y = row[indexes[:y]].to_f

        coord = SVY21.to_wgs84(x, y)

        db.exec <<-SQL, carpark_number, address, coord[:lat], coord[:lon]
          INSERT OR REPLACE INTO carpark_infos (carpark_number, address, latitude, longitude)
          VALUES (?, ?, ?, ?)
        SQL
      end
    end
    puts "Static info loaded from file."
  end

  def self.load_availability
    puts "Fetching availability..."

    url = "https://api.data.gov.sg/v1/transport/carpark-availability"
    response = HTTP::Client.get(url)
    json = JSON.parse(response.body)

    items = json["items"].as_a.first
    carparks = items["carpark_data"].as_a

    db do |db|
      carparks.each do |cp|
        number = cp["carpark_number"].as_s
        lots_info = cp["carpark_info"].as_a.first

        total = lots_info["total_lots"].as_s.to_i
        available = lots_info["lots_available"].as_s.to_i

        db.exec <<-SQL, number, total, available
          INSERT OR REPLACE INTO carpark_availabilities (carpark_number, total_lots, available_lots)
          VALUES (?, ?, ?)
        SQL
      end
    end

    puts "Availability loaded."
  end

  def self.load_all
    load_static_info
    load_availability
  end
end
