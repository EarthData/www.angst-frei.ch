var map = L.map('map', {
  center: [46.9, 8.4], // EDIT latitude, longitude to re-center map
  zoom: 7,  // EDIT from 1 to 18 -- decrease to zoom out, increase to zoom in
  scrollWheelZoom: true
});

/* Control panel to display map layers */
var controlLayers = L.control.layers( null, null, {
  position: "topright",
  collapsed: false
}).addTo(map);

L.Control.geocoder().addTo(map);

var maskIcon = L.icon({
    iconUrl: '/assets/img/laden.png',
    iconSize:     [20, 20], // size of the icon
});

// display Carto basemap tiles with light features and labels
var light = L.tileLayer('https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png', {
  attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>, &copy; <a href="https://carto.com/attribution">CARTO</a>.'
}).addTo(map); // EDIT - insert or remove ".addTo(map)" before last semicolon to display by default
controlLayers.addBaseLayer(light, 'Einfache Karte');

/* Stamen colored terrain basemap tiles with labels */
var terrain = L.tileLayer('https://stamen-tiles.a.ssl.fastly.net/terrain/{z}/{x}/{y}.png', {
  attribution: 'ap tiles by <a href="http://stamen.com">Stamen Design</a>, under <a href="http://creativecommons.org/licenses/by/3.0">CC BY 3.0</a>. Data by <a href="http://openstreetmap.org">OpenStreetMap</a>, under <a href="http://www.openstreetmap.org/copyright">ODbL</a>.'
}); // EDIT - insert or remove ".addTo(map)" before last semicolon to display by default
controlLayers.addBaseLayer(terrain, 'Erweiterte Karte');

// see more basemap options at https://leaflet-extras.github.io/leaflet-providers/preview/
geocoder = new L.Control.Geocoder.Nominatim();

// Read markers data from data.csv
$.get('/assets/data/lokal_schweiz.csv', function(csvString) {

  // Use PapaParse to convert string to array of objects
  var data = Papa.parse(csvString, {header: true, dynamicTyping: true, skipEmptyLines: true}).data;

  // For each row in data, create a marker and add it to the map
  // For each row, columns `Latitude`, `Longitude`, and `Title` are required
  for (var i in data) {

    var row = data[i]

    var description = "<strong>" + row.name + "</strong><br/>" + row.strasse + "<br/>" + row.postleitzahl + " " + row.ort + "<br/>" + row.tel + "<br/><br/>"

    if (row.url) {
      description += "<a href=\"" + row.url + "\">" + row.url + "</a><br/><br/>"
    }

    description += "&Ouml;ffnungszeiten:<br/>"
  
    description += "<table>"
    description += "<tr><td>Montag</td><td>" + row.mo + "</td></tr>"
    description += "<tr><td>Dienstag</td><td>" + row.di + "</td></tr>"
    description += "<tr><td>Mittwoch</td><td>" + row.mi + "</td></tr>"
    description += "<tr><td>Donnerstag</td><td>" + row.do + "</td></tr>"
    description += "<tr><td>Freitag</td><td>" + row.fr + "</td></tr>"
    description += "<tr><td>Samstag</td><td>" + row.sa + "</td></tr>"
    description += "<tr><td>Sonntag</td><td>" + row.so + "</td></tr>"
    description += "</table><br/><br/>"
    
    if (row.besonderes) {
      description +=  "Besonderes: " + row.besonderes 
    }
    
    if (row['latitude'] != null) {
      var marker = L.marker([row['latitude'], row['longitude']], {icon: maskIcon}, {
        opacity: 1
      }).bindPopup(description)
      marker.addTo(map)
    } else {
      console.log("Keine Koordinaten verfügbar");
      console.log(row);
    }
  }

})
