---
layout:     minimal
full-width: true
ext-js:     ["//unpkg.com/dat.gui", "//unpkg.com/three", "//unpkg.com/3d-force-graph"]
css:        ["/assets/css/link-graph.css"]
---

<!--
  <script src="//unpkg.com/dat.gui"></script>
  <script src="//unpkg.com/three"></script>
  <script src="//unpkg.com/3d-force-graph"></script>
-->
  <script src="//unpkg.com/d3-dsv"></script>
  <script src="//unpkg.com/dat.gui"></script>
  <script src="//unpkg.com/d3-octree"></script>
  <script src="//unpkg.com/d3-force-3d"></script>
  <script src="//unpkg.com/3d-force-graph"></script>

<div id="graph"></div>

<script type="module">

fetch('json/inside-corona.json').then(res => res.json()).then(gData => {

  gData.links.forEach(link => {
    const a = gData.nodes[link.source];
    const b = gData.nodes[link.target];
    !a.neighbors && (a.neighbors = []);
    !b.neighbors && (b.neighbors = []);
    a.neighbors.push(b);
    b.neighbors.push(a);

    !a.links && (a.links = []);
    !b.links && (b.links = []);
    a.links.push(link);
    b.links.push(link);
  });

  const highlightNodes = new Set();
  const highlightLinks = new Set();
  let hoverNode = null;

  const Graph = ForceGraph3D()
    (document.getElementById('graph'))
    .nodeThreeObject(node => {
      const imgTexture = new THREE.TextureLoader().load(`${node.image}`);
      const material = new THREE.SpriteMaterial({ map: imgTexture });
      const sprite = new THREE.Sprite(material);
      sprite.scale.set(12, 12);
      return sprite;
    })
    .graphData(gData)
    .dagMode('td')
    .nodeLabel('title')
    .nodeAutoColorBy('group')
    .linkLabel('title')
    //.linkWidth(link => link.state == "current" ? 1 : 0.5)
    .linkWidth(link => highlightLinks.has(link) ? 1 : 0.5)
    .linkDirectionalParticles(link => highlightLinks.has(link) ? 2 : 0)
    .linkDirectionalParticleWidth(1)
    .onNodeHover(node => {
      // no state change
      if ((!node && !highlightNodes.size) || (node && hoverNode === node)) return;

      highlightNodes.clear();
      highlightLinks.clear();
      if (node) {
        highlightNodes.add(node);
        node.neighbors.forEach(neighbor => highlightNodes.add(neighbor));
        node.links.forEach(link => highlightLinks.add(link));
      }

      hoverNode = node || null;

      updateHighlight();
    })
    .onLinkHover(link => {
      highlightNodes.clear();
      highlightLinks.clear();

      if (link) {
        highlightLinks.add(link);
        highlightNodes.add(link.source);
        highlightNodes.add(link.target);
      }

      updateHighlight();
    })
    .linkOpacity(0.4)
    .linkAutoColorBy('group')
    .onNodeClick(node => {
      if (node.link.length) {
        window.open(node.link);
        window.focus();
      }
    })
    .onNodeRightClick(node => {
      // Aim at node from outside it
      const distance = 40;
      const distRatio = 1 + distance/Math.hypot(node.x, node.y, node.z);
      Graph.cameraPosition(
        { x: node.x * distRatio, y: node.y * distRatio, z: node.z * distRatio }, // new position
        node, // lookAt ({ x, y, z })
        3000  // ms transition duration
      );
    })
    .onNodeDragEnd(node => {
      node.fx = node.x;
      node.fy = node.y;
      node.fz = node.z;
    })
    .onLinkClick(link => {
      if (link.link.length) {
        window.open(link.link);
        window.focus();
      }
    });

  const linkForce = Graph
    .d3Force('link')
    .distance(link => settings.Length)

  const settings = { 'Orientation': 'td', 'Length': 80, 'Mode': 3 };
  const gui = new dat.GUI();

  gui.add(settings, 'Orientation', ['td', 'bu', 'lr', 'rl', 'zout', 'zin', 'radialout', 'radialin', null])
      .onChange(orientation => Graph && Graph.dagMode(orientation) && Graph.numDimensions(settings.Mode));
  gui.add(settings, 'Mode', ['3', '2', '1'])
      .onChange(mode => Graph && Graph.dagMode(settings.Orientation) && Graph.numDimensions(mode));

  const settingsLength = gui.add(settings, 'Length', 0, 200);
  settingsLength.onChange(updateLinkDistance);

  function updateLinkDistance() {
    linkForce.distance(link => settings.Length);
    Graph.numDimensions(3); // Re-heat simulation
  }

  function updateHighlight() {
  // trigger update of highlighted objects in scene
  Graph
    .linkWidth(Graph.linkWidth())
    .linkDirectionalParticles(Graph.linkDirectionalParticles());
  }

});

  </script>
<body>
