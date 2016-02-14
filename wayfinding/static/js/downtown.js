'use strict';

var map = L.map('map').setView([44.0539, -123.0944], 12);

// http://a.tile.stamen.com/toner/${z}/${x}/${y}.png
L.tileLayer("http://a.tile.stamen.com/toner-lite/{z}/{x}/{y}.png", { maxzoom : 18 }).addTo(map)

