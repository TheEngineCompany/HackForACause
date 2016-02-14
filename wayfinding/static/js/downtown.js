'use strict';

var map = L.map('map').setView([44.0539, -123.0944], 12);

// http://a.tile.stamen.com/toner/${z}/${x}/${y}.png
L.tileLayer("http://a.tile.stamen.com/toner-lite/{z}/{x}/{y}.png", { maxzoom : 18 }).addTo(map)

var outline = { "type":"Feature", "geometry": {"type":"Polygon","coordinates":[[[-123.100365600495,44.045516028131],[-123.100365600495,44.0587890681825],[-123.079038340709,44.0587890681825],[-123.079038340709,44.045516028131],[-123.100365600495,44.045516028131]]]}, "properties": { "label": "Eugene Downtown" }}

L.geoJson(outline).addTo(map)
