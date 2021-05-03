var nodes = null;
var edges = null;
var network = null;

function destroy() {
  if (network !== null) {
    network.destroy();
    network = null;
  }
}

function draw() {
  destroy();
  nodes = [];
  edges = [];
  var connectionCount = [];

  edges.push({ from: 0,  to: 11, arrows: "to" });
  edges.push({ from: 0,  to: 13, arrows: "to" });
  edges.push({ from: 0,  to: 24, arrows: "to" });
  edges.push({ from: 22, to: 11, arrows: "to" });
  edges.push({ from: 21, to: 12, arrows: "to" });
  edges.push({ from: 23, to: 14, value: 3 });
  edges.push({ from: 24, to: 15, arrows: "to" });
  edges.push({ from: 22, to: 16, arrows: "to" });
  edges.push({ from: 0,  to: 21, arrows: "to" });
  edges.push({ from: 1,  to: 11, value: 3 });
  edges.push({ from: 1,  to: 12, value: 3 });
  edges.push({ from: 1,  to: 13, value: 3 });
  edges.push({ from: 1,  to: 14, value: 3 });
  edges.push({ from: 1,  to: 15, value: 3 });
  edges.push({ from: 1,  to: 16, value: 3 });
  edges.push({ from: 10, to: 0,  value: 3 });
  edges.push({ from: 17, to: 0,  value: 3 });
  edges.push({ from: 10, to: 1,  value: 3 });
  edges.push({ from: 17, to: 1,  value: 3 });
  
  nodes.push({ id: 0,  label: "Angst",      level: 0, color: "darkgrey" });
  nodes.push({ id: 1,  label: "Körper",     level: 5, color: "gold" });
  nodes.push({ id: 10, label: "",           level: 3, color: "blue" });
  nodes.push({ id: 11, label: "Hirn",       level: 3, color: "silver" });
  nodes.push({ id: 12, label: "Lunge",      level: 3, color: "aqua" });
  nodes.push({ id: 13, label: "Herz",       level: 3, color: "chartreuse" });
  nodes.push({ id: 14, label: "Leber",      level: 3, color: "red", font: { color: "white" }});
  nodes.push({ id: 15, label: "Niere",      level: 3, color: "blue", font: { color: "white" }});
  nodes.push({ id: 16, label: "Milz",       level: 3, color: "black", font: { color: "white" }});
  nodes.push({ id: 17, label: "",           level: 3, color: "red" });
  nodes.push({ id: 21, label: "Todesangst", level: 2 });
  nodes.push({ id: 22, label: "Neid",       level: 2 });
  nodes.push({ id: 23, label: "Wut",        level: 2, color: "red", font: { color: "white" }});
  nodes.push({ id: 24, label: "Sorge",      level: 2 });

  // create a network
  var container = document.getElementById("mynetwork");
  var data = {
    nodes: nodes,
    edges: edges,
  };

  var options = {
    edges: {
      smooth: {
        type: "cubicBezier",
        forceDirection: "horizontal",
        roundness: 0.4,
      },
    },
    layout: {
      hierarchical: {
        direction: "LR",
        sortMethod: "hubsize",
        shakeTowards: "roots",
      },
    },
    physics: false,
  };
  network = new vis.Network(container, data, options);

  // add event listeners
  network.on("select", function (params) {
    document.getElementById("selection").innerText =
      "Selection: " + params.nodes;
  });
}


window.addEventListener("load", () => {
  draw();
});
