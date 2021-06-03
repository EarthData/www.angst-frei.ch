$.getJSON('/json/network-person-data.json', function(data) {

  var options = {
    nodes:{
      borderWidth: 0,
      shape: 'circularImage',
    },
    edges: {
      smooth: {
        forceDirection: "none"
      }
    },
    physics: {
      minVelocity: 0.75,
      solver: "forceAtlas2Based"
    }
  };

  // create a network
  var container = document.getElementById("mynetwork");
  var network = new vis.Network(container, data, options);

});
