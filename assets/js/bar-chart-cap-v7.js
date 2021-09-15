var margin = {top: 30, right: 70, bottom: 40, left: 40},
  width = parseInt(d3.select('#ch-icu').style('width'), 10),
  width = width - margin.left - margin.right,
  height = 500 - margin.top - margin.bottom;

var parseTime  = d3.timeParse("%Y-%m-%d");

const graph = async (region, type, ydomain) => {

  var title = region + " Spital-Betten " + type.toUpperCase();

  var group = region.toLowerCase() + "-" + type;

  var graph = await d3.csv("data_hosp_processed/hosp_" + region + "-" + type + ".csv")
    .then(function(data) {

    data.forEach(function(d) {
      d.day = parseTime(d.day);
    });

    var keys = data.columns.slice(1)

    var color = d3.scaleOrdinal()
      .domain(keys)
      .range(["#660099", "#B319FF", "#99FF66"]);

    //stack the data?
    var stackedData = d3.stack()
      .keys(keys)
      (data)

    var svg = d3.select("#" + group)
      .append("svg")
      .attr("width", width + margin.left + margin.right)
      .attr("height", height + margin.top + margin.bottom)
      .append("g")
      .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

    svg.append("text")
      .attr("x", (width / 2))
      .attr("y", 0 - (margin.top / 2))
      .attr("text-anchor", "middle")
      .style("font-size", "16px")
      .style("text-decoration", "underline")
      .text(title);

    // Add X axis
    var x = d3.scaleTime()
      .domain(d3.extent(data, function(d) { return d.day; }))
      .range([ 0, width ]);

    var xAxis = svg.append("g")
      .attr("transform", `translate(0, ${height})`)
      .call(d3.axisBottom(x).ticks(10))

    // Add Y axis
    const y = d3.scaleLinear()
      .domain([0, ydomain])
      .range([ height, 0 ]);

    svg.append("g")
      .call(d3.axisLeft(y).ticks(5))

    //////////
    // BRUSHING AND CHART //
    //////////

    // Add a clipPath: everything out of this area won't be drawn.
    const clip = svg.append("defs").append("svg:clipPath")
      .attr("id", "clip")
      .append("svg:rect")
      .attr("width", width )
      .attr("height", height )
      .attr("x", 0)
      .attr("y", 0);

    // Add brushing
    const brush = d3.brushX()                 // Add the brush feature using the d3.brush function
      .extent( [ [0,0], [width,height] ] ) // initialise the brush area: start at 0,0 and finishes at width,height: it means I select the whole graph area
      .on("end", updateChart) // Each time the brush selection changes, trigger the 'updateChart' function

    // Create the scatter variable: where both the circles and the brush take place
    const areaChart = svg.append('g')
      .attr("clip-path", "url(#clip)")

    // Area generator
    const area = d3.area()
      .x(function(d) { return x(d.data.day); })
      .y0(function(d) { return y(d[0]); })
      .y1(function(d) { return y(d[1]); })

    // Show the areas
    areaChart
      .selectAll("mylayers")
      .data(stackedData)
      .join("path")
      .attr("class", function(d) { return group + "-area " + group + "-area-" + d.key })
      .style("fill", function(d) { return color(d.key); })
      .attr("d", area)

    // Add the brushing
    areaChart
      .append("g")
      .attr("class", "brush")
      .call(brush);

    let idleTimeout
    function idled() { idleTimeout = null; }

    // A function that update the chart for given boundaries
    function updateChart(event,d) {

      extent = event.selection

      // If no selection, back to initial coordinate. Otherwise, update X axis domain
      if(!extent){
        if (!idleTimeout) return idleTimeout = setTimeout(idled, 350); // This allows to wait a little bit
        x.domain(d3.extent(data, function(d) { return d.day; }))
      } else {
        x.domain([ x.invert(extent[0]), x.invert(extent[1]) ])
        areaChart.select(".brush").call(brush.move, null) // This remove the grey brush area as soon as the selection has been done
      }

      // Update axis and area position
      xAxis.transition().duration(1000).call(d3.axisBottom(x).ticks(5))
      areaChart
        .selectAll("path")
        .transition().duration(1000)
        .attr("d", area)
    }

    //////////
    // HIGHLIGHT GROUP //
    //////////

    // What to do when one group is hovered
    const highlight = function(event,d){
      // reduce opacity of all groups
      d3.selectAll("." + group + "-area")
        .style("opacity", .1)
      // expect the one that is hovered
      d3.select("." + group + "-area-" + d).style("opacity", 1)
    }

    // And when it is not hovered anymore
    const noHighlight = function(event,d){
      d3.selectAll("." + group + "-area").style("opacity", 1)
    }

    //////////
    // LEGEND //
    //////////

    // Add one dot in the legend for each name.
    const size = 15
    svg.selectAll("myrect")
      .data(keys)
      .join("rect")
      .attr("x", width - 80)
      .attr("y", function(d,i){ return 0 + i*(size+5)}) // 100 is where the first dot appears. 25 is the distance between dots
      .attr("width", size)
      .attr("height", size)
      .style("fill", function(d){ return color(d)})
      .on("mouseover", highlight)
      .on("mouseleave", noHighlight)

    // Add one dot in the legend for each name.
    svg.selectAll("mylabels")
      .data(keys)
      .join("text")
      .attr("x", width - 80 + size*1.2)
      .attr("y", function(d,i){ return 0 + i*(size+5) + (size/2)}) // 100 is where the first dot appears. 25 is the distance between dots
      .style("fill", "black")
      .text(function(d){ return d})
      .attr("text-anchor", "left")
      .style("alignment-baseline", "middle")
      .on("mouseover", highlight)
      .on("mouseleave", noHighlight)
    
  })
  .catch(function(error){
    throw error;
  })

}

const build = async () => {
  await graph("CH", "nonicu", 25000);
  await graph("CH", "icu", 1600);
  await graph("ZH", "nonicu", 5000);
  await graph("ZH", "icu", 500);
  await graph("AG", "nonicu", 1500);
  await graph("AG", "icu", 100);
  await graph("BE", "nonicu", 3500);
  await graph("BE", "icu", 150);
  await graph("GE", "nonicu", 3200);
  await graph("GE", "icu", 140);
  await graph("SG", "nonicu", 1500);
  await graph("SG", "icu", 100);
  await graph("SO", "nonicu", 600);
  await graph("SO", "icu", 40);
  await graph("SZ", "nonicu", 400);
  await graph("SZ", "icu", 20);
}

build();

