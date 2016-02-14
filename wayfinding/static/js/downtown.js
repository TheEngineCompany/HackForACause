'use strict';

var data_url = '/dwtn/make_json';

var map = L.map('map').setView([44.0539, -123.0944], 12);

// http://a.tile.stamen.com/toner/${z}/${x}/${y}.png
L.tileLayer("http://a.tile.stamen.com/toner-lite/{z}/{x}/{y}.png", { maxzoom : 18 }).addTo(map)

var outline = { "type":"Feature", "geometry": {"type":"Polygon","coordinates":[[[-123.100365600495,44.045516028131],[-123.100365600495,44.0587890681825],[-123.079038340709,44.0587890681825],[-123.079038340709,44.045516028131],[-123.100365600495,44.045516028131]]]}, "properties": { "label": "Eugene Downtown" }}

L.geoJson(outline).addTo(map)


function error_message() {
	// really terrible error message
	var error_msg = "Whups, tell houston we've had a bad problem :/";
	
	var error_div = document.createElement("div");
	error_div.classList.add("error")
	error_div.innerHTML = error_msg;
	console.log(error_msg);
	
	document.getElementsByTagName('body')[0].appendChild(error_div);
}

var request = new XMLHttpRequest();
request.open('GET', data_url);
request.onload = function() {
	if (this.status >= 200 && this.status <= 400) {
		var data = JSON.parse(this.response);
		console.log(data)
	} else {
		console.log("error 1")
		error_message();
	}
}

request.send();
