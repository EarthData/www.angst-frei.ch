$.getJSON('/json/network-link-data.json', function(data) {


  function draw() {

    // create a network
    var container = document.getElementById("mynetwork");

    const options = {
      "edges": {
        "smooth": {
          "forceDirection": "none"
        }
      },
      "physics": {
        "forceAtlas2Based": {
          "springLength": 100
        },
        "minVelocity": 0.75,
        "solver": "forceAtlas2Based"
      }
    }

    // create a network
    var container = document.getElementById("mynetwork");
    var network = new vis.Network(container, data, options);
  };
  draw();

});
