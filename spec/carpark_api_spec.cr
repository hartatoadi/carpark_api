require "./spec_helper"
require "../src/services/carpark_fetcher"

describe CarparkFetcher do
  it "fetches carpark data and calculates distance" do
    latitude = -6.175110
    longitude = 106.865036

    results = CarparkFetcher.fetch(latitude, longitude)

    results.should_not be_empty

    first_carpark = results.first
    first_carpark["distance_km"].should be_a(Float64)

    first_carpark["carpark_number"].should_not be_nil
    first_carpark["address"].should_not be_nil
  end

  it "returns a sorted list by distance" do
    latitude = -6.175110
    longitude = 106.865036
    results = CarparkFetcher.fetch(latitude, longitude)

    distances = results.map { |r| r["distance_km"].as_f }
    distances.should eq(distances.sort)
  end
end
