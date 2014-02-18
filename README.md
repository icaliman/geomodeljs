# geomodel.js

This library is an implementation of the Geomodel/Geocell concept:

http://code.google.com/apis/maps/articles/geospatial.html

It is a direct port of the Java and Python versions of the geomodel project:

- http://code.google.com/p/javageomodel/
- http://code.google.com/p/geomodel/

Most of the code for the core Geocell concept was ported from the Java version.
The proximity\_fetch implementation was ported from the Python version, with 
the "entity" store abstracted out to remove the coupling to Google App Engine.
Also, this proximity\_fetch does not directly support the execution of an
additional query to filter the promixity results with, though this could be
implemented in whatever entity finder function the user passes to it.   

A geocell is a hexadecimal string that defines a two dimensional rectangular
region inside the [-90,90] x [-180,180] latitude/longitude space. A geocell's
'resolution' is its length. For most practical purposes, at high resolutions,
geocells can be treated as single points.

Much like geohashes (see http://en.wikipedia.org/wiki/Geohash), geocells are 
hierarchical, in that any prefix of a geocell is considered its ancestor, with
geocell[:-1] being geocell's immediate parent cell.

To calculate the rectangle of a given geocell string, first divide the
[-90,90] x [-180,180] latitude/longitude space evenly into a 4x4 grid like so:

<pre>
               +---+---+---+---+ (90, 180)
               | a | b | e | f |
               +---+---+---+---+
               | 8 | 9 | c | d |
               +---+---+---+---+
               | 2 | 3 | 6 | 7 |
               +---+---+---+---+
               | 0 | 1 | 4 | 5 |
    (-90,-180) +---+---+---+---+
</pre>

NOTE: The point (0, 0) is at the intersection of grid cells 3, 6, 9 and c. And,
for example, cell 7 should be the sub-rectangle from (-45, 90) to (0, 180).   

Calculate the sub-rectangle for the first character of the geocell string and
re-divide this sub-rectangle into another 4x4 grid. For example, if the geocell
string is '78a', we will re-divide the sub-rectangle like so:

<pre>
                 .                   .
                 .                   .
             . . +----+----+----+----+ (0, 180)
                 | 7a | 7b | 7e | 7f |
                 +----+----+----+----+
                 | 78 | 79 | 7c | 7d |
                 +----+----+----+----+
                 | 72 | 73 | 76 | 77 |
                 +----+----+----+----+
                 | 70 | 71 | 74 | 75 |
    . . (-45,90) +----+----+----+----+
                 .                   .
                 .                   .
</pre>

Continue to re-divide into sub-rectangles and 4x4 grids until the entire
geocell string has been exhausted. The final sub-rectangle is the rectangular
region for the geocell.    

## Usage

Create a Geomodel instance:

    var geomodel = require('geomodel').create_geomodel();

For detailed usage see <code>test/index.coffee</code>

## Testing

For testing you need to install nodeunit module:

    # npm install nodeunit -g
    # cd test & nodeunit index.coffee