# HDB Carpark Finder API

A simple Crystal/Kemal-based API that returns nearby carparks sorted by distance with real-time availability.

## Features

- Convert SVY21 coordinates to WGS84
- Load static carpark info from CSV
- Load real-time availability from Singapore Data Gov API
- Compute distance using Haversine formula
- Serve results via `/carparks?latitude=...&longitude=...` endpoint
- Sorts by distance ascending
- [Bonus] Unit-tested

## Usage

```bash
# Install dependencies
shards install

# Load database
crystal fetch_data.cr

# Run the API
crystal run src/carpark_api.cr
```

## Example Request

```bash
GET /carparks?latitude=1.29587&longitude=103.85847
```