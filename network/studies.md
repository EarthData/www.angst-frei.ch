---
layout:     minimal
full-width: true
ext-js:     ["//unpkg.com/3d-force-graph"]
css:        ["/assets/css/link-graph.css"]
---

<div id="graph"></div>

<script type="module">

  const Graph = ForceGraph3D()
    (document.getElementById('graph'))
      .jsonUrl('/json/network-studies-data.json')
      .nodeLabel('title')
      .nodeVal('value')
      .nodeAutoColorBy('group')
      .linkWidth('value')
      .linkLabel('title')
      .linkAutoColorBy('group')
      .onNodeClick(node => {
        if (node.link.length) {
          window.open(node.link);
          window.focus();
        }
      })
      .onNodeDragEnd(node => {
        node.fx = node.x;
        node.fy = node.y;
        node.fz = node.z;
      });
</script>
