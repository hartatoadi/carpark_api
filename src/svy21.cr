module SVY21
  # Constants used in SVY21 formula
  A = 6378137.0
  F = 1 / 298.257223563
  O = 1.0 - F
  B = A * O
  E2 = (2 * F) - (F ** 2)

  ORIGIN_LAT = deg_to_rad(1.366666)   # degrees to radians
  ORIGIN_LON = deg_to_rad(103.833333)
  FALSE_N = 38744.572
  FALSE_E = 28001.642
  K = 1.0

  def self.deg_to_rad(deg : Float64) : Float64
    deg * Math::PI / 180.0
  end

  def self.rad_to_deg(rad : Float64) : Float64
    rad * 180.0 / Math::PI
  end

  def self.to_wgs84(easting : Float64, northing : Float64) : NamedTuple(lat: Float64, lon: Float64)
    n = A / Math.sqrt(1 - E2 * Math.sin(ORIGIN_LAT) ** 2)
    t0 = Math.tan(ORIGIN_LAT)
    rho = A * (1 - E2) / ((1 - E2 * Math.sin(ORIGIN_LAT) ** 2) ** 1.5)
    psi = n / rho

    n_prime = northing - FALSE_N
    e_prime = easting - FALSE_E

    m = n_prime / K
    mu = m / (A * (1 - E2 / 4 - 3 * E2 ** 2 / 64 - 5 * E2 ** 3 / 256))

    e1 = (1 - Math.sqrt(1 - E2)) / (1 + Math.sqrt(1 - E2))
    j1 = 3 * e1 / 2 - 27 * e1 ** 3 / 32
    j2 = 21 * e1 ** 2 / 16 - 55 * e1 ** 4 / 32
    j3 = 151 * e1 ** 3 / 96
    j4 = 1097 * e1 ** 4 / 512

    fp = mu + j1 * Math.sin(2 * mu) + j2 * Math.sin(4 * mu) + j3 * Math.sin(6 * mu) + j4 * Math.sin(8 * mu)

    sin_fp = Math.sin(fp)
    cos_fp = Math.cos(fp)
    tan_fp = Math.tan(fp)

    e2_sq = E2 / (1 - E2)
    c1 = e2_sq * cos_fp ** 2
    t1 = tan_fp ** 2
    r1 = A * (1 - E2) / ((1 - E2 * sin_fp ** 2) ** 1.5)
    n1 = A / Math.sqrt(1 - E2 * sin_fp ** 2)
    d = e_prime / (n1 * K)

    lat = fp - (n1 * tan_fp / r1) * (
      d ** 2 / 2 -
      (5 + 3 * t1 + 10 * c1 - 4 * c1 ** 2 - 9 * e2_sq) * d ** 4 / 24 +
      (61 + 90 * t1 + 298 * c1 + 45 * t1 ** 2 - 252 * e2_sq - 3 * c1 ** 2) * d ** 6 / 720
    )

    lon = ORIGIN_LON + (
      d -
      (1 + 2 * t1 + c1) * d ** 3 / 6 +
      (5 - 2 * c1 + 28 * t1 - 3 * c1 ** 2 + 8 * e2_sq + 24 * t1 ** 2) * d ** 5 / 120
    ) / cos_fp

    { lat: rad_to_deg(lat), lon: rad_to_deg(lon) }
  end
end
