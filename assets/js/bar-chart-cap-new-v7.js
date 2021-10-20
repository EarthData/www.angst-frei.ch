var margin = {top: 30, right: 70, bottom: 40, left: 40},
  width = parseInt(d3.select('#ch-icu').style('width'), 10),
  width = width - margin.left - margin.right,
  height = 500 - margin.top - margin.bottom;

var y_orig = {};
var active_link = {};
var legendClassArray = {};
var nodes = {};
var idx = {};

var parseTime  = d3.timeParse("%Y-%m-%d");

// List of groups (here I have one group per column)
var allGroup = ["CH", "ZH", "AG", "AI", "AR", "BE", "BL", "BS", "FR", "GE", "GL", "GR", "JU", "LU", "NE", "NW", "OW", "SG", "SH", "SO", "SZ", "TG", "TI", "UR", "VD", "VS", "ZG"]
var divs = ["ch-icu", "ch-nonicu", "region-icu", "region-nonicu"]

divs.forEach(function(d) {
  d3.select("#" + d).append("svg")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom)
    .attr("class", "svg-" + d)
});

// add the options to the button
d3.select("#selectButton")
  .selectAll('myOptions')
  .data(allGroup)
  .enter()
  .append('option')
  .text((d) => d) // text showed in the menu
  .attr('value', (d) => d) // corresponding value returned by the button

const graph = async (region, type) => {

  if (type == "covid") {
    var title = region + " Hospitalisationen nach Alter (Covid) ";
  } else {
    var title = region + " Hospitalisationen nach Alter (Covid-geimpft) ";
  }

  var group = region == "CH" ? region.toLowerCase() + "-" + type : "region-" + type;

  active_link[group] = "0"; //to control legend selections and hover
  legendClassArray[group] = []; //store legend classes to select bars in plotSingle()
  y_orig[group]; //to store original y-posn

  var graph = await d3.csv("data_hosp_processed/hosp_" + region + "-" + type + ".csv")
    .then(function(data) {

    var keys = data.columns.slice(1)

    data.forEach(function(d) {
      for (i = 0, t = 0; i < keys.length; ++i) t += d[keys[i]] = +d[keys[i]];
      d.total = t;
      //y0 = 0;
      d.day = parseTime(d.day);
      //d.types = keys.map(function(name) { return {myday: d.day, name: name, y0: y0, y1: y0 += +d[name]}; });
    });

    var x = d3.scaleTime()
      .domain(d3.extent(data, (d) => d.day))
      .range([0, width - 24]);

    var y = d3.scaleLinear()
      .domain([0, d3.max(data, (d) => d.total)]).nice()
      .rangeRound([height, 0]);

    var color = d3.scaleOrdinal()
      .domain(keys)
      .range(["#660099", "#B319FF", "#99FF66"]);

    var stackedData = d3.stack()
      .keys(keys)
      (data)

    var xAxis = d3.axisBottom(x);
    var yAxis = d3.axisLeft(y).tickFormat(d3.format(".2s"));

    d3.selectAll(".g-" + group)
      .remove()

    var svg = d3.select('.svg-' + group)
      .append('g')
      .attr('class', 'g-' + group)
      .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')');
   
    svg.append('g')
      .attr('class', 'x axis')
      .call(xAxis)
      .attr('transform', 'translate(0,' + height + ')')

    svg.append('g')
      .attr('class', 'y axis')
      .call(yAxis)

    svg.append('text')
      .attr('x', (width / 2))
      .attr('y', 0 - (margin.top / 2))
      .attr('text-anchor', 'middle')
      .attr('class', 'title-' + group)
      .style('font-size', '16px')
      .style('text-decoration', 'underline')
      .text(title)

    var state = svg.selectAll('.state')
      .data(stackedData)
      .join('path')
      .transition()
      .ease(d3.easeLinear)
      .duration(800)
      .delay(function (d, i) {
          return i * 50;
      })
      .attr("d", d3.area()
        .x((d) => x(d.data.day))
        .y0((d) => y(d[0]))
        .y1((d) => y(d[1]))
      )
      .attr('fill', (d) => color(d.key))
      .attr('class', (d) => 'class-' + group + '-' + d.key.replace(/\s/g, ''))
      .style('opacity', 1);

/*
    state.selectAll("rect")
     .on("mouseover", function(d,i){
        var delta = i.y1 - i.y0;
        var xPos = parseFloat(d3.select(this).attr("x"));
        var yPos = parseFloat(d3.select(this).attr("y"));
        var height = parseFloat(d3.select(this).attr("height"))
        d3.select(this).attr("stroke","blue").attr("stroke-width",0.8);
        svg.append("text")
          .attr("x", xPos)
          .attr("y", yPos + height/2)
          .attr("class", group + "-tooltip")
          .text(i.name + ": " + delta);
      })

      .on("mouseout",function(){
        svg.select("." + group + "-tooltip").remove();
        d3.select(this).attr("stroke","pink").attr("stroke-width",0.2);
      })
*/

      var legend = svg.selectAll(".legend")
        .data(color.domain().slice().reverse())
        .enter().append("g")
        .attr("id", function (d) {
          legendClassArray[group].push(group + "-" + d.replace(/\s/g, '')); //remove spaces
          return "legend-" + group;
        })
        .attr("transform", function(d, i) { return "translate(50," + i * 20 + ")"; });

      //reverse order to match order in which bars are stacked
      legendClassArray[group] = legendClassArray[group].reverse();

      legend.append("rect")
        .attr("x", width - 18)
        .attr("width", 18)
        .attr("height", 18)
        .style("fill", color)
        .attr("id", function (d, i) {
          return "id-" + group + "-" + d.replace(/\s/g, '');
        })

      .on("mouseover",function() {
        if (active_link[group] === "0") d3.select(this).style("cursor", "pointer");
        else {
          if (active_link[group].split("class").pop() === this.id.replace('id-','')) {
            d3.select(this).style("cursor", "pointer");
          } else d3.select(this).style("cursor", "auto");
        }
      })

      .on("click",function(d, i) {
        let id = this.id.matchAll(/^id-([a-z]{2,6})-([a-z]+)-(.*)/g);
        id = Array.from(id);
        group = id[0][1] + "-" + id[0][2]
        if (active_link[group] === "0") { //nothing selected, turn on this selection
          d3.select(this)
            .style("stroke", "black")
            .style("stroke-width", 2);
            active_link[group] = this.id.replace('id-','');
            plotSingle(this);
            //gray out the others
            for (j = 0; j < legendClassArray[group].length; j++) {
              if (legendClassArray[group][j] != active_link[group]) {
                d3.select("#id-" + group + "-" + legendClassArray[group][j])
                  .style("opacity", 0.5);
              }
            }
        } else { //deactivate
          if (active_link[group] === this.id.replace('id-','')) {//active square selected; turn it OFF
            d3.select(this)
              .style("stroke", "none");
            active_link[group] = "0"; //reset
            //restore remaining boxes to normal opacity
            for (j = 0; j < legendClassArray[group].length; j++) {
              d3.select("#id-" + group + "-" + legendClassArray[group][j])
                .style("opacity", 1);
            }
            //restore plot to original
            restorePlot(d, group);
          }
        } //end active_link check
      });
  
      legend.append("text")
        .attr("x", width - 24)
        .attr("y", 9)
        .attr("dy", ".35em")
        .style("text-anchor", "end")
        .text(function(d) { return d; });
  
      function restorePlot(d, group) {
/*
        state.nodes().forEach(function(d, i) {
          nodes[group] = d.childNodes;
          //restore shifted bars to original posn
          d3.select(nodes[group][idx[group]])
            .transition()
            .duration(1000)
            .attr("y", y_orig[group][i]);
        })
*/
        //restore opacity of erased bars
        for (i = 0; i < legendClassArray[group].length; i++) {
          if (legendClassArray[group][i] != class_keep) {
            d3.selectAll(".class-" + legendClassArray[group][i])
              .transition()
              .duration(1000)
              .delay(750)
              .style("opacity", 1);
          }
        }
      }
  
      function plotSingle(d) {
        class_keep = d.id.replace('id-','');
        group = d.parentElement.id.replace('legend-','');
        idx[group] = legendClassArray[group].indexOf(class_keep);
        //erase all but selected bars by setting opacity to 0
        for (i = 0; i < legendClassArray[group].length; i++) {
          if (legendClassArray[group][i] != class_keep) {
            d3.selectAll(".class-" + legendClassArray[group][i])
              .transition()
              .duration(1000)
              .style("opacity", 0);
          }
        }

/*
        //lower the bars to start on x-axis
        y_orig[group] = [];

        state.nodes().forEach(function(d, i) {
          nodes[group] = d.childNodes;
          //get height and y posn of base bar and selected bar
          console.log(d3.select(nodes[group][idx[group]]));
          h_keep = d3.select(nodes[group][idx[group]]).attr("y1");
          y_keep = d3.select(nodes[group][idx[group]]).attr("y0");

          console.log(h_keep);
          console.log(y_keep);
            
          //store y_base in array to restore plot
          y_orig[group].push(y_keep);

          h_base = d3.select(nodes[group][0]).attr("y1");
          y_base = d3.select(nodes[group][0]).attr("y0");

          h_shift = h_keep - h_base;
          y_new = y_base - h_shift;

          //reposition selected bars
          d3.select(nodes[group][idx[group]])
            .transition()
            .ease(d3.easeBounce)
            .duration(1000)
            .delay(750)
            .attr("y1", h_shift)
            .attr("y0", y_new);
        })
*/
    }
  })
  .catch(function(error){
    throw error;
  })

}

const build = async () => {
  await graph("CH", "icu");
  await graph("CH", "nonicu");
  await graph("ZH", "icu");
  await graph("ZH", "nonicu");
}

build();

// When the button is changed, run the updateChart function
d3.select("#selectButton").on("change", function(d) {
  var selectedOption = d3.select(this).property("value")
  changeDrop(selectedOption)
})

const changeDrop = async(region) => {
  await graph(region, "icu");
  await graph(region, "nonicu");
}
