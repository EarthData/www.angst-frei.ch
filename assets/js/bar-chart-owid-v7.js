var margin = {top: 30, right: 70, bottom: 40, left: 40},
  width = parseInt(d3.select('#CHE').style('width'), 10),
  width = width - margin.left - margin.right,
  height = 500 - margin.top - margin.bottom;


var x = d3.scaleTime()
  .range([0, width]);

var y0 = d3.scaleLinear()
  .range([height, 0]);
var y1 = d3.scaleLinear()
  .range([height, 0]);

var y0_values = ["new_cases", "new_vaccinations"]
var y1_values = ["new_deaths"]
var y_values  = y0_values.concat(y1_values);

var colors0 = ["blue", "green"]
var colors1 = ["black"]
var colors  = colors0.concat(colors1);

var z0 = d3.scaleOrdinal()
  .range(colors0);
var z1 = d3.scaleOrdinal()
  .range(colors1);
var z = d3.scaleOrdinal()
  .range(colors);

var xAxis      = d3.axisBottom(x);
var yAxisLeft  = d3.axisLeft(y0).tickFormat(d3.format(".2s"));
var yAxisRight = d3.axisRight(y1).tickFormat(d3.format(".2s"));

var parseTime  = d3.timeParse("%Y-W%W");
    bisectDate = d3.bisector(function(d) { return d.date; }).left;

const graph = async (country) => {

  var title = country;

  d3.csv("data_owid_processed/data_owid_" + country + ".csv")
    .then(function(data) {

    data.forEach(function(d) {
      d.date = parseTime(d.date);
    });

    var svg = d3.select("#" + country).append("svg")
      .attr("width", width + margin.left + margin.right)
      .attr("height", height + margin.top + margin.bottom)
      .attr("class", "svg-" + country)
      .append("g")
      .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

    svg.append("text")
      .attr("x", (width / 2))
      .attr("y", 0 - (margin.top / 2))
      .attr("text-anchor", "middle")
      .style("font-size", "16px")
      .style("text-decoration", "underline")
      .text(title);

    var line0 = d3.line()
      .curve(d3.curveBasis)
      .x(function(d) {
        return x(d.date);
      })
      .y(function(d) {
        return y0(d.line);
      });

    var line1 = d3.line()
      .curve(d3.curveBasis)
      .x(function(d) {
        return x(d.date);
      })
      .y(function(d) {
        return y1(d.line);
      });

    z.domain(y_values);
    z0.domain(y0_values);
    z1.domain(y1_values);

    var fields = z.domain().map(function(name) {
      return {
        name: name,
        values: data.map(function(d) {
          return { date: d.date, line: +d[name] };
        })
      };
    });

    var fields0 = z0.domain().map(function(name) {
      return {
        name: name,
        values: data.map(function(d) {
          return { date: d.date, line: +d[name] };
        })
      };
    });

    var fields1 = z1.domain().map(function(name) {
      return {
        name: name,
        values: data.map(function(d) {
          return { date: d.date, line: +d[name] };
        })
      };
    });

    x.domain(d3.extent(data, function(d) { return d.date; }));

    y0.domain([
      d3.min(fields0, function(c) {
        return d3.min(c.values, function(v) {
          return v.line;
        });
      }),
      d3.max(fields0, function(c) {
        return d3.max(c.values, function(v) {
          return v.line;
        });
      })
    ]);

    y1.domain([
      d3.min(fields1, function(c) {
        return d3.min(c.values, function(v) {
          return v.line;
        });
      }),
      d3.max(fields1, function(c) {
        return d3.max(c.values, function(v) {
          return v.line;
        });
      })
    ]);

    var legend = svg.selectAll('g')
      .data(fields)
      .enter()
      .append('g')
      .attr('class', 'legend');

    legend.append('rect')
      .attr('x', width - 100)
      .attr('y', function(d, i) {
        return i * 20;
      })
      .attr('width', 10)
      .attr('height', 10)
      .style('fill', function(d) {
        return z(d.name);
      });

    legend.append('text')
      .attr('x', width - 88)
      .attr('y', function(d, i) {
        return (i * 20) + 9;
      })
      .text(function(d) {
        return d.name;
      });

    svg.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0," + height + ")")
      .call(xAxis);

    svg.append("g")
      .attr("class", "y axis")
      .call(yAxisLeft)
      .append("text")
      .attr("transform", "rotate(-90)")
      .attr("y", 6)
      .attr("dy", ".71em")
      .style("text-anchor", "end")
      .text("per million");

    svg.append("g")				
      .attr("class", "y axis")	
      .attr("transform", "translate(" + width + " ,0)")	
      .style("fill", "red")		
      .call(yAxisRight);

    var singlevalue0 = svg.selectAll("." + country)
      .data(fields0)
      .enter().append("g")
      .attr("class", country + "-lines-group");

    singlevalue0.append("path")
      .attr("class", `${country}-line0 ${country}-lines`)
      .attr("d", function(d) {
        return line0(d.values);
      })
      .style("stroke", function(d) {
        return z0(d.name);
      })
      //Our new hover effects
      .on('mouseover', function (d, i) {
        d3.select(this).transition()
          .duration('50')
          .attr('opacity', '.5');
      })
      .on('mouseout', function (d, i) {
        d3.select(this).transition()
          .duration('50')
          .attr('opacity', '1');
      });

    var singlevalue1 = svg.selectAll("." + country)
      .data(fields1)
      .enter().append("g")
      .attr("class", country + "-lines-group");

    singlevalue1.append("path")
      .attr("class", `${country}-line1 ${country}-lines`)
      .attr("d", function(d) {
        return line1(d.values);
      })
      .style("stroke", function(d) {
        return z1(d.name);
      })
      //Our new hover effects
      .on('mouseover', function (d, i) {
        d3.select(this).transition()
          .duration('50')
          .attr('opacity', '.5');
      })
      .on('mouseout', function (d, i) {
        d3.select(this).transition()
          .duration('50')
          .attr('opacity', '1');
      });

    var mouseG = svg.append("g")
      .attr("class", country + "-mouse-over-effects");

    mouseG.append("path") // this is the black vertical line to follow mouse
      .attr("class", country + "-mouse-line")
      .style("stroke", "black")
      .style("stroke-width", "1px")
      .style("opacity", "0");
      
    var lines = document.getElementsByClassName(country + "-lines");

    var mousePerLine = mouseG.selectAll("." + country + "-mouse-per-line")
      .data(fields)
      .enter()
      .append("g")
      .attr("class", country + "-mouse-per-line");

    mousePerLine.append("circle")
      .attr("r", 7)
      .style("stroke", function(d) {
        return z(d.name);
      })
      .style("fill", "none")
      .style("stroke-width", "1px")
      .style("opacity", "0");

    mousePerLine.append("text")
      .attr("transform", "translate(10,3)");

    mouseG.append('svg:rect') // append a rect to catch mouse movements on canvas
      .attr('width', width) // can't catch mouse events on a g element
      .attr('height', height)
      .attr('fill', 'none')
      .attr('pointer-events', 'all')
      .on('mouseout', function() { // on mouse out hide line, circles and text
        d3.select("." + country + "-mouse-line")
          .style("opacity", "0");
        d3.selectAll("." + country + "-mouse-per-line circle")
          .style("opacity", "0");
        d3.selectAll("." + country + "-mouse-per-line text")
          .style("opacity", "0");
      })
      .on('mouseover', function() { // on mouse in show line, circles and text
        d3.select("." + country + "-mouse-line")
          .style("opacity", "1");
        d3.selectAll("." + country + "-mouse-per-line circle")
          .style("opacity", "1");
        d3.selectAll("." + country + "-mouse-per-line text")
          .style("opacity", "1");
      })
      .on('mousemove', function() { // mouse moving over canvas
        var mouse = d3.pointer(event);
        d3.select("." + country + "-mouse-line")
          .attr("d", function() {
            var d = "M" + mouse[0] + "," + height;
            d += " " + mouse[0] + "," + 0;
            return d;
          });

        d3.selectAll("." + country + "-mouse-per-line")
          .attr("transform", function(d, i) {
            //console.log(width/mouse[0])
            var xDate = x.invert(mouse[0]),
                bisect = d3.bisector(function(d) { return d.date; }).right;
                idx = bisect(d.values, xDate);
            
            var beginning = 0,
                end = lines[i].getTotalLength(),
                target = null;

            while (true){
              target = Math.floor((beginning + end) / 2);
              pos = lines[i].getPointAtLength(target);
              if ((target === end || target === beginning) && pos.x !== mouse[0]) {
                  break;
              }
              if (pos.x > mouse[0])      end = target;
              else if (pos.x < mouse[0]) beginning = target;
              else break; //position found
            }
            
            d3.select(this).select('text')
              .text(y0.invert(pos.y).toFixed(2));
              
            return "translate(" + mouse[0] + "," + pos.y +")";
          });
      });
  })
  .catch(function(error){
    throw error;
  })

}

const build = async () => {
  await graph("CHE");
  await graph("DEU");
  await graph("AUT");
  await graph("ISL");
  await graph("GBR");
  await graph("IND");
  await graph("USA");
  await graph("ISR");
}

build();
