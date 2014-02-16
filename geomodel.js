exports.create_geomodel = function () {

    var GEOCELL_DEFAULT_HASH_SIZE = 8;
    var GEOCELL_GRID_SIZE = 4;
    var GEOCELL_ALPHABET = "0145236789cdabef";

    var map = [], imap = [];

    var pos = 0;
    for (var i = 0; i < GEOCELL_GRID_SIZE; i++) {
        map[i] = []
        for (var j = 0; j < GEOCELL_GRID_SIZE; j++) {
            var ch = GEOCELL_ALPHABET[pos++];
            map[i][j] = ch;
            imap[ch] = {row: i, col: j};
        }
    }

    return {
        compute_hash: function (lat, lon, hash_size) {
            if (lat > 90.0 || lat < -90.0) {
                throw new Error("Latitude must be in [-90, 90] but was " + lat);
            }
            if (lon > 180.0 || lon < -180.0) {
                throw new Error("Longitude must be in [-180, 180] but was " + lon);
            }

            hash_size = hash_size || GEOCELL_DEFAULT_HASH_SIZE;

            var north = 90.0;
            var south = -90.0;
            var east = 180.0;
            var west = -180.0;

            var hash = "";

            for (var i = 0; i < hash_size; i++) {
                var dx = (east - west) / GEOCELL_GRID_SIZE;
                var dy = (north - south) / GEOCELL_GRID_SIZE;

                var col = Math.min(Math.floor(GEOCELL_GRID_SIZE * (lon - west) / (east - west)),
                    GEOCELL_GRID_SIZE - 1);
                var row = Math.min(Math.floor(GEOCELL_GRID_SIZE * (lat - south) / (north - south)),
                    GEOCELL_GRID_SIZE - 1);

                south += row * dy;
                north = south + dy;

                west += col * dx;
                east = west + dx;

                hash += map[row][col];
            }
            return hash;
        },

        compute_box: function (hash) {
            hash = hash.toLowerCase();

            var north = 90.0;
            var south = -90.0;
            var east = 180.0;
            var west = -180.0;
            var hash_size = hash.length;

            for (var i = 0; i < hash_size; i++) {
                var ch = hash[i];

                if (GEOCELL_ALPHABET.indexOf(ch) == -1) {
                    throw new Error("Hash contines incorrect character: " + ch);
                }

                var row = imap[ch].row;
                var col = imap[ch].col;

                var dx = (east - west) / GEOCELL_GRID_SIZE;
                var dy = (north - south) / GEOCELL_GRID_SIZE;

                south += row * dy;
                north = south + dy;

                west += col * dx;
                east = west + dx;
            }

            return {
                northEast: {
                    lat: north,
                    lon: east
                },
                southWest: {
                    lat: south,
                    lon: west
                },
                getNorth: function() {
                    return this.northEast.lat;
                },
                getSouth: function() {
                    return this.southWest.lat;
                },
                getWest: function() {
                    return this.southWest.lon;
                },
                getEast: function() {
                    return this.northEast.lon;
                }
            }
        }
    }
}
