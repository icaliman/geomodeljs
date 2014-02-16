geomodel = require("../index.js").create_geomodel()

exports.testIfHashIsEqualForSameCoords = (test) ->
  hash = geomodel.compute_hash(23.454545, 44.123123)
  i = 0
  while i < 1000
    hash1 = geomodel.compute_hash(23.454545, 44.123123)
    test.equal hash1, hash, "Hash must be equal for same coords."
    ++i
  test.done()

exports.testIfCoordsAreEqualForSameHash = (test) ->
  coords = geomodel.compute_box("AFCD352E")
  i = 0
  while i < 1000
    coords1 = geomodel.compute_box("AFCD352E")
    test.deepEqual coords1.northEast, coords.northEast, "Coords must be equal for same hash."
    test.deepEqual coords1.southWest, coords.southWest, "Coords must be equal for same hash."
    ++i
  test.done()

exports.testFinal = (test) ->
  h = "ABFC1485FF"
  b = geomodel.compute_box(h)
  lat = (b.northEast.lat + b.southWest.lat) / 2
  lon = (b.northEast.lon + b.southWest.lon) / 2
  hh = geomodel.compute_hash(lat, lon, 10)
  test.equal hh.toLowerCase(), h.toLowerCase(), "Hashes must be equal..."
  test.done()

exports.testCoordsForNeighborFields = (test) ->
  h1 = "AC3D17F23"
  h2 = "AC3D17F26"
  h3 = "AC3D17F2D"
  h4 = "AC3D17F27"
  c1 = geomodel.compute_box(h1)
  c2 = geomodel.compute_box(h2)
  c3 = geomodel.compute_box(h3)
  c4 = geomodel.compute_box(h4)
  test.ok c1.northEast.lat is c2.northEast.lat and c1.southWest.lat is c2.southWest.lat, "c1, c2 : Latitude must be equal."
  test.ok c1.northEast.lon is c2.southWest.lon, "Max longitude of first field must be equal with min longitude of second field."
  test.done()

exports.testIfErrorIsThrownWhenCoordinatesAreNotInInterval = (test) ->
  test.throws (->
    geomodel.compute_hash -91, 44.123123
  ), Error, "compute_hash must throw an error if latitude is not in interval [-90, 90]"
  test.throws (->
    geomodel.compute_hash -90, 181
  ), Error, "compute_hash must throw an error if longitude is not in interval [-180, 180]"
  test.throws (->
    geomodel.compute_hash 12, -180.00000001
  ), Error, "compute_hash must throw an error if longitude is not in interval [-180, 180]"
  test.done()

exports.testIfErrorIsThrownWhenHashContinesIncorrectCharacters = (test) ->
  test.throws (->
    geomodel.compute_box "ASDFGHJK"
  ), Error, "compute_box must throw an error if hash contines incorrect characters"
  test.throws (->
    geomodel.compute_box "0123456789_"
  ), Error, "compute_box must throw an error if hash contines incorrect characters"
  test.throws (->
    geomodel.compute_box "01234567894342432Q"
  ), Error, "compute_box must throw an error if hash contines incorrect characters"
  test.done()