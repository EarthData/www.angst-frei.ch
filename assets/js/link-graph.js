$.getJSON('/json/network-link-data.json', function(data) {

  var options = {
    physics: {
      forceAtlas2Based: {
        springLength: 100
      },
      minVelocity: 0.75,
      solver: "forceAtlas2Based"
    },
    nodes: {
      shape: "dot",
      scaling: {
        customScalingFunction: function (min, max, total, value) {
          return value / total;
        },
        min: 5,
        max: 150,
      },
    },
  };

  // create a network
  var container = document.getElementById("mynetwork");
  var network = new vis.Network(container, data, options);

});
