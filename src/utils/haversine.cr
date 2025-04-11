module Haversine
  def self.calculate(lat1 : Float64, lon1 : Float64, lat2 : Float64, lon2 : Float64) : Float64
    r = 6371.0
    dlat = (lat2 - lat1) * Math::PI / 180.0
    dlon = (lon2 - lon1) * Math::PI / 180.0
    a = Math.sin(dlat / 2)**2 + Math.cos(lat1 * Math::PI / 180.0) * Math.cos(lat2 * Math::PI / 180.0) * Math.sin(dlon / 2)**2
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
    r * c
  end
end