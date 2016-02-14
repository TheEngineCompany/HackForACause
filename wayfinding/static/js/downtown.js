'use strict';

var data_url = '/dwtn/make_json';

var map = L.map('map').setView([44.0539, -123.0944], 12);

// http://a.tile.stamen.com/toner/${z}/${x}/${y}.png
L.tileLayer("http://a.tile.stamen.com/toner-lite/{z}/{x}/{y}.png", { maxzoom : 18 }).addTo(map)

// outline downtown
var outline = { "type":"Feature", "geometry": {"type":"Polygon","coordinates":[[[-123.100365600495,44.045516028131],[-123.100365600495,44.0587890681825],[-123.079038340709,44.0587890681825],[-123.079038340709,44.045516028131],[-123.100365600495,44.045516028131]]]}, "properties": { "label": "Eugene Downtown" }}
L.geoJson(outline).addTo(map)

if (navigator.geolocation) {
	console.log("mebe?")
}


function render_category(category) {
	
	var cat_li = document.createElement("li");
	cat_li.classList.add("category");
	cat_li.setAttribute("style", "background-color:" + category.color + ";");
	cat_li.setAttribute("data-id", category.id);
	
	var cat_title = document.createElement("h3");
	cat_title.textContent = category.name;
	cat_li.appendChild(cat_title);
	
	var cat_loc_list = document.createElement("ul");
	cat_li.appendChild(cat_loc_list);
	
	document.getElementById('categories').appendChild(cat_li);
}

function generate_menu(data) {
	console.log(data)
	for (var i=0; i<data.categories.length; i++) {
		render_category(data.categories[i]);
	}
	for (var i=0; i<data.locations.length; i++) {
		var coords = L.latLng(data.locations[i].lat, data.locations[i].lon);
		L.marker(coords, { "title": data.locations[i].name, "riseOnHover": true }).addTo(map)
	}
}

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
		// hurray, you some datums
		
		var data = JSON.parse(this.response);
		generate_menu(data)
		
		
	} else {
		console.log("error 1")
		error_message();
	}
}

request.send();
