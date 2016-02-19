'use strict';

var data_url = '/dwtn/make_json';

var map = L.map('map').setView([44.0539, -123.0944], 12, {"animate": true});

// http://a.tile.stamen.com/toner/${z}/${x}/${y}.png
L.tileLayer("http://a.tile.stamen.com/toner-lite/{z}/{x}/{y}.png", { maxzoom : 18 }).addTo(map)

// outline downtown
var outline = { "type":"Feature", "geometry": {"type":"Polygon","coordinates":[[[-123.100365600495,44.045516028131],[-123.100365600495,44.0587890681825],[-123.079038340709,44.0587890681825],[-123.079038340709,44.045516028131],[-123.100365600495,44.045516028131]]]}, "properties": { "label": "Eugene Downtown" }}
L.geoJson(outline).addTo(map)

var my_coords = null

function you_are_here(lat, lon) {
	if (! my_marker) {
		var my_marker = L.marker(L.latLng(lat, lon), {"icon": L.divIcon({"html": 'You Are Here', "className": 'marker myMarker' }), }).addTo(map);
	}
	else {
		console.log(my_marker)
	}
	my_coords = L.LatLng(lat, lon);
	console.log(my_coords)
	console.log(lat, lon)
}

if (navigator.geolocation) {
	function geo_success(position) {
		you_are_here(position.coords.latitude, position.coords.longitude);
	}

	var geo_options = {
	  enableHighAccuracy: true,
	  maximumAge        : 30000,
	  timeout           : 27000
	};

	var wpid = navigator.geolocation.watchPosition(geo_success, function() {}, geo_options);
}

function activate_marker(e) {
	console.log(e, my_coords)
	if (my_coords) {
		console.log(e)
		console.log(route, L.route)
	}
}

function category(name, color) {
	this.name = name;
	this.color = color;
	
	var li = document.createElement("li");
	li.classList.add("category");
	li.setAttribute("style", "background-color:" + category.color + ";");
	li.setAttribute("data-category-id", category.id);
	
	var title = document.createElement("h3");
	title.textContent = category.name;
	li.appendChild(title);
	
	var locations = document.createElement("ul");
	locations.classList.add("locations");
	locations.setAttribute("id", 'category_' + category.id + '_loclist');
	li.appendChild(locations);
	
	document.getElementById('categories').appendChild(cat_li);
	
}

function location(lat, lon, category, name, details, image) {
	this.coordinates = L.LatLng(lat, lon);
	this.category = data.categories.filter(function(c) { return c.id == data.locations[i].catid })[0];
	this.name = name;
	this.details = details;
	this.imagePath = image;
	
	var li = document.createElement("li");
	li.classList.add("location");
	li.textContent = data.locations[i].name;
	document.getElementById('category_' + category.id + '_loclist').appendChild(li);
	
	this.marker = L.marker(coords, { "title": data.locations[i].name, "icon": category.icon, "riseOnHover": true })
	this.marker.on("click", activate_marker)
	this.marker.addTo(map)
}

function render_category(category) {
	
	var cat_li = document.createElement("li");
	cat_li.classList.add("category");
	cat_li.setAttribute("style", "background-color:" + category.color + ";");
	cat_li.setAttribute("data-id", category.id);
	
	var cat_title = document.createElement("h3");
	cat_title.textContent = category.name;
	cat_li.appendChild(cat_title);
	
	var loc_list = document.createElement("ul");
	loc_list.classList.add("locations");
	loc_list.setAttribute("id", 'category_' + category.id + '_loclist');
	cat_li.appendChild(loc_list);
	
	document.getElementById('categories').appendChild(cat_li);
}

function generate_menu(data) {
	var categorized = []
	console.log(data)
	
	for (var i=0; i<data.categories.length; i++) {
		render_category(data.categories[i]);
		var catclass = "marker_cat_" + data.categories[i].id
		data.categories[i].icon = L.divIcon({"className": "marker " + catclass, "html": data.categories[i].name.charAt(0).toUpperCase() })
	}
	for (var i=0; i<data.locations.length; i++) {
		
		var category = data.categories.filter(function(cat) {
			return cat.id == data.locations[i].catid;
		})[0];
		
		var loc_li = document.createElement("li");
		loc_li.classList.add("location");
		loc_li.textContent = data.locations[i].name;
		document.getElementById('category_' + category.id + '_loclist').appendChild(loc_li);
		
		var coords = L.latLng(data.locations[i].lat, data.locations[i].lon);
		var marker = L.marker(coords, { "title": data.locations[i].name, "icon": category.icon, "riseOnHover": true })
		marker.on("click", activate_marker)
		marker.addTo(map)
	}
}

function main(data) {
	
	generate_menu(data)
	
	// set colors of markers
	for (var i=0; i<data.categories.length; i++) {
		var markers = document.getElementsByClassName('marker_cat_' + data.categories[i].id)
		
		for (var n = 0; n < markers.length; n++) {
			markers[n].style.backgroundColor = data.categories[i].color;
		}
	}
	
}

// get JSON data from server
var request = new XMLHttpRequest();
request.open('GET', data_url);
request.onload = function() {
	if (this.status >= 200 && this.status <= 400) {
		// hurray, we got some datums
		var data = JSON.parse(this.response);
		main(data)
		
	} else {
		alert("sorry, something went wrong while fetching data from the server")
	}
}

request.send();
