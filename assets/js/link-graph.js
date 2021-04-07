$.getJSON('/json/network-link-data.json', function(data) {

  var options = {};

  // create a network
  var container = document.getElementById("mynetwork");
  var network = new vis.Network(container, data, options);

});
