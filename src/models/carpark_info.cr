struct CarparkInfo
  property carpark_number : String
  property address : String
  property lat : Float64
  property long : Float64

  def initialize(@carpark_number : String, @address : String, @lat : Float64, @long : Float64)
  end
end
