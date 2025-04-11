struct CarparkAvailability
  property carpark_number : String
  property total_lots : Int32
  property available_lots : Int32

  def initialize(@carpark_number : String, @total_lots : Int32, @available_lots : Int32)
  end
end
