$.getJSON('/json/network-link-data.json', function(data) {


  function draw() {

    // create a network
    var container = document.getElementById("mynetwork");

    var options = {
      nodes: {
        shape: "dot",
      },
      physics: {
        stabilization: false,
        wind: { x: 0, y: 0 },
      },
      configure: {
        filter: function (option, path) {
          if (path.indexOf("physics") !== -1) {
            return true;
          }
          if (path.indexOf("smooth") !== -1 || option === "smooth") {
            return true;
          }
          return false;
        },
        container: document.getElementById("config"),
      },
    };
    network = new vis.Network(container, data, options);
  }

  window.addEventListener("load", () => {
    draw();
});

//  var options = {
//    physics: {
//      forceAtlas2Based: {
//        springLength: 100
//      },
//      minVelocity: 0.75,
//      solver: "forceAtlas2Based"
//    },
//    nodes: {
//      shape: "dot",
//      scaling: {
//        label: {
//          min: 8,
//          max: 20,
//        },
//      },
//    },
//  };

  // create a network
//  var container = document.getElementById("mynetwork");
//  var network = new vis.Network(container, data, options);

});
