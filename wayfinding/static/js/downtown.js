'use strict';

var data_url = '/dwtn/make_json';

var map = L.map('map').setView([44.0539, -123.0944], 12, {"animate": true});

// http://a.tile.stamen.com/toner/${z}/${x}/${y}.png
L.tileLayer("http://a.tile.stamen.com/toner-lite/{z}/{x}/{y}.png", { maxzoom : 18 }).addTo(map)

// outline downtown
// var outline = { "type":"Feature", "geometry": {"type":"Polygon","coordinates":[[[-123.100365600495,44.045516028131],[-123.100365600495,44.0587890681825],[-123.079038340709,44.0587890681825],[-123.079038340709,44.045516028131],[-123.100365600495,44.045516028131]]]}, "properties": { "label": "Eugene Downtown" }}
// L.geoJson(outline).addTo(map)

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

function getAutoHeight(elem) {
	var test_elem = elem.cloneNode(true);
	test_elem.style.visibility = "hidden";
	test_elem.style.height = "auto";
	document.body.appendChild(test_elem);

	var height = getComputedStyle(test_elem)["height"];
	test_elem.remove();
	
	return height;
}

function Sidebar() {
	this.categories = [];
	this.focusedCategory = null;
	
	function focusCategory(focusCategory) {
		map.closePopup();
		
		if (focusCategory === this.focusedCategory) {
			this.categories.forEach(function(c){
				c.collapse();
				c.showMarkers();
			});
			this.focusedCategory = null;
		}
		else {
			this.categories.forEach(function(c) {
				if (c == focusCategory) {
					c.expand();
					c.showMarkers();
					c.focusMarkers();
				}
				else {
					c.collapse();
					c.hideMarkers();
				}
			});
			this.focusedCategory = focusCategory;
		}
	}
			
	this.addCategory = function(category) {
		category.li.addEventListener("click", focusCategory.bind(this, category));
		this.categories.push(category);
	}
	
}

function Category(name, color, id) {
	this.name = name;
	this.color = color;
	this.id = id;
	this.icon = null;
	this.attractions = [];
	
		
	this.collapse = function() {
		this.collapsed = true;
		this.attractionList.style.height = 0;
	}
	this.expand = function() {
		this.collapsed = false;
		this.attractionList.style.height = this.defaultHeight;
	}
	
	this.hideMarkers = function() {
		var markers = document.querySelectorAll(".marker.category-" + this.id);
		
		Array.prototype.forEach.call(markers, function(marker) {
			marker.style.visibility = "hidden";
		});
	}
	this.showMarkers = function() {
		var markers = document.querySelectorAll(".marker.category-" + this.id);
		
		Array.prototype.forEach.call(markers, function(marker) {
			marker.style.visibility = "visible";
		});
	}
	
	this.focusMarkers = function() {
		var bounds = L.latLngBounds(this.attractions.map(function(o) {return o.coordinates}));
		map.fitBounds(bounds, {paddingTopLeft: [200, 0]});
	}
	
	var catclass = "category-" + this.id;
	var firstletter = this.name.charAt(0).toUpperCase();
	this.icon = L.divIcon({
		"className": "marker " + catclass,
		"html": firstletter
	});
	
	this.li = document.createElement("li");
	this.li.classList.add("category");
	this.li.style.backgroundColor = this.color;
	this.li.setAttribute("data-category-id", this.id);
	
	var title = document.createElement("h3");
	title.textContent = this.name;
	this.li.appendChild(title);
	
	this.attractionList = document.createElement("ul");
	this.attractionList.classList.add("locations");
	//locations.setAttribute("id", 'category_' + this.id + '_loclist');
	this.li.appendChild(this.attractionList);
	// this.li.addEventListener("click", this.toggle.bind(this));
	document.getElementById('categories').appendChild(this.li);
	// make everything collapsed initially
	
	this.collapse();
	
	function handleMq(mql) {
		if (mql.matches) {
			document.body.insertBefore(this.attractionList, document.getElementById('map'));
			this.attractionList.style.backgroundColor = this.color;
		}
		else {
			this.li.appendChild(this.attractionList);
		}
	}
	
	var mql = window.matchMedia("(max-width: 700px)");
	mql.addListener(handleMq.bind(this));
	
	// in case mediaquery is already in effect, test it right away
	handleMq.bind(this, mql)()
	
}

function Attraction(lat, lon, category, name, details, imageUrl) {
	this.coordinates = new L.LatLng(lat, lon);
	this.category = category;
	this.name = name;
	this.details = details;
	this.imageUrl = imageUrl;

	var li = document.createElement("li");
	li.classList.add("location");
	li.textContent = this.name;
	this.category.attractionList.appendChild(li);
	
	this.marker = L.marker(this.coordinates, { "title": this.name, "icon": this.category.icon, "riseOnHover": true })
	
	var thumbnail = document.createElement("div");
	thumbnail.classList.add("thumbnail");
	thumbnail.style.backgroundImage = `url("static/${this.imageUrl}")`;
	
	var name = document.createElement("h4");
	name.classList.add("name");
	name.textContent = this.name;
	
	var description = document.createElement("span");
	description.textContent = this.details;
	
	var caption = document.createElement("p");
	caption.classList.add("description");
	caption.appendChild(name);
	caption.appendChild(description);
	
	
	var popup_content = document.createElement("div");
	popup_content.appendChild(thumbnail);
	popup_content.appendChild(caption);
	
	var markerPopup = L.popup({"closeButton": false, "className": "locationPopup"})
		.setContent(popup_content)
	
	this.marker.bindPopup(markerPopup);
	this.marker.addTo(map)
	
	li.addEventListener("mouseover", function() {
		this.marker.openPopup();
	}.bind(this))
}


function generate_menu(data) {
	// var categorized = []
	console.log(data)
	var sidebar = new Sidebar();
	
	for (var i=0; i<data.categories.length; i++) {
		
		var c = data.categories[i];
		var category = new Category(c.name, c.color, c.id);
		sidebar.addCategory(category);
		
		// get all attractions with an id coorisponding to the current category
		var attractions = data.locations.filter(function(a) { return a.catid == c.id });
		
		for (var n=0; n<attractions.length; n++) {
			// put attraction info into an Attraction object and put it in our category
			var a = attractions[n];
			var attraction = new Attraction(a.lat, a.lon, category, a.name, a.details, a.img);
			
			category.attractions.push(attraction);
		}
		
		// store height of uncollapsed list, needed to workaround css inability to animate between a px value to height:auto
		category.defaultHeight = getAutoHeight(category.attractionList);
	}
	
}

function main(data) {
	
	generate_menu(data)
	
	// set colors of markers
	for (var i=0; i<data.categories.length; i++) {
		var markers = document.querySelectorAll('.marker.category-' + data.categories[i].id)
		
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
