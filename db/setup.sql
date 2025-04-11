DROP TABLE IF EXISTS carpark_infos;
CREATE TABLE carpark_infos (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  carpark_number TEXT UNIQUE,
  address TEXT,
  latitude REAL,
  longitude REAL
);

DROP TABLE IF EXISTS carpark_availabilities;
CREATE TABLE carpark_availabilities (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  carpark_number TEXT,
  total_lots INTEGER,
  available_lots INTEGER,
  UNIQUE(carpark_number)
);
