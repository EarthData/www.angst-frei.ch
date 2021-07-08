

const geolong = {CH: "CH", CH011: "VD", CH012: "VS", CH013: "GE", CH021: "BE", CH022: "FR", CH023: "SO", CH024: "NE", CH025: "JU", CH031: "BS", CH032: "BL", CH033: "AG", CH040: "ZH", CH051: "GL", CH052: "SH", CH053: "AR", CH054: "AI", CH055: "SG", CH056: "GR", CH057: "TG", CH061: "LU", CH062: "UR", CH063: "SZ", CH064: "OW", CH065: "NW", CH066: "ZG", CH070: "TI"};
const geoshort = {CH: "Switzerland", VD: "Vaud", VS: "Valais", GE: "Genève", BE: "Bern", FR: "Freiburg", SO: "Solothurn", NE: "Neuchâtel", JU: "Jura", BS: "Basel-Stadt", BL: "Basel-Landschaft", AG: "Aargau", ZH: "Zürich", GL: "Glarus", SH: "Schaffhausen", AR: "Appenzell Ausserrhoden", AI: "Appenzell Innerrhoden", SG: "St. Gallen", GR: "Graubünden", TG: "Thurgau", LU: "Luzern", UR: "Uri", SZ: "Schwyz", OW: "Obwalden", NW: "Nidwalden", ZG: "Zug", TI: "Ticino"};

const regions = ['CH', 'AG', 'AI', 'AR', 'BE', 'BL', 'BS', 'FR', 'GE', 'GL', 'GR', 'JU', 'LU', 'NE', 'NW', 'OW', 'SG', 'SH', 'SO', 'SZ', 'TG', 'TI', 'UR', 'VD', 'VS', 'ZG', 'ZH']
const ages = ['Y0T4', 'Y5T9', 'Y10T14', 'Y15T19', 'Y20T24', 'Y25T29', 'Y30T34', 'Y35T39', 'Y40T44', 'Y45T49', 'Y50T54', 'Y55T59', 'Y60T64', 'Y65T69', 'Y70T74', 'Y75T79', 'Y80T84', 'Y85T89', 'Y_GE90'].reverse();

const parseDay           = d3.timeParse("%Y-%m-%d");
const parseWeek          = d3.timeParse("%Y-%W");
const year_week_formater = d3.timeFormat('%Y-%W');
const week_formater      = d3.timeFormat('%W');
const year_formater      = d3.timeFormat('%Y');
const average = list => list.reduce((prev, curr) => prev + curr) / list.length;

// set dimensions
const divWidth = 1200;
const divHeight = 800;
const margin = {top: 20, right: 20, bottom: 30, left: 40}
const width = divWidth - margin.left - margin.right
const height = divHeight - margin.top - margin.bottom

// set the colors
//var colors = d3.schemeSpectral[11].reverse();
//var colors = d3.scaleSequential().domain([1, 19]).range([0, 1])
const colors = d3.schemeSpectral[11];

// set x scale
var x = d3.scaleBand()
  .rangeRound([0, width - 80])
  .paddingInner(0.05)
  .align(0.1)
// set y scale
var y = d3.scaleLinear()
  .rangeRound([height, 0]);
// set z scale
var z = d3.scaleOrdinal()
  .range(colors);

const graph = async (year) => {

  var cum_data = {};
  cum_data['death_data'] = await load_death(year);
  cum_data['corona_data'] = await load_corona();

  var death_data = cum_data['death_data']
  console.log(death_data);

  if (cum_data['corona_data'][year]) {
    var corona_data = cum_data['corona_data'][year]
    corona_data['geo'] = cum_data['corona_data']['geo']
  }

  var chart_data = {};
  var sum_data = {};
  var weeks = d3.range(1, 53)

  for (var geo of regions) {
    chart_data[geo] = [];
    sum_data[geo] = [];
    for (var week of weeks) {
      var values = {}
      values['week'] = week;
      var total = 0
      if (death_data[geo] && death_data[geo][week]) {
        for (var age of ages) {
          if (death_data[geo][week][age]) {
            values[age] = death_data[geo][week][age]['T']
            total += death_data[geo][week][age]['T']
          } else {
            values[age] = 0;
          }
        };
      } else {
        for (var age of ages) {
          values[age] = 0;
        };
        total = 0;
      };
      sum_data[geo].push(total);
      chart_data[geo].push(values)
    };
  };

  if (cum_data['corona_data'][year]) {
    var line_data = {};
    var sum_corona_data = {};

    for (var geo of regions.filter((value)=>value!='CH')) {
      line_data[geo] = [];
      for (var week of weeks) {
        if (!sum_corona_data[week]) {
           sum_corona_data[week] = {};
           sum_corona_data[week]['deceased'] = 0;
           sum_corona_data[week]['tested'] = 0;
           sum_corona_data[week]['positive'] = 0;
           sum_corona_data[week]['vent'] = 0;
        }
        var values = {}
        values['week'] = week;
        if (corona_data[geo][week-1] && corona_data[geo][week]) {
          if (corona_data[geo][week]['deceased'] >= corona_data[geo][week-1]['deceased']) {
            values['deceased'] = corona_data[geo][week]['deceased'] - corona_data[geo][week-1]['deceased']
          } else {
            values['deceased'] = 0;
            corona_data[geo][week]['deceased'] = corona_data[geo][week-1]['deceased'];
          }
          values['tested']   = corona_data[geo][week]['tested']   - corona_data[geo][week-1]['tested']
          values['positive'] = corona_data[geo][week]['positive'] - corona_data[geo][week-1]['positive']
          values['vent']     = corona_data[geo][week]['vent'].length > 0 ? average(corona_data[geo][week]['vent']) : 0
        } else if (corona_data[geo][week]) {
          values['deceased'] = corona_data[geo][week]['deceased']
          values['tested']   = corona_data[geo][week]['tested']
          values['positive'] = corona_data[geo][week]['positive']
          values['vent']     = corona_data[geo][week]['vent'].length > 0 ? average(corona_data[geo][week]['vent']) : 0
        } else {
          values['deceased'] = 0
          values['tested']   = 0
          values['positive'] = 0
          values['vent']     = 0
        }
        sum_corona_data[week]['deceased'] += values['deceased']
        sum_corona_data[week]['tested']   += values['tested']
        sum_corona_data[week]['positive'] += values['positive']
        sum_corona_data[week]['vent']     += values['vent']
        line_data[geo].push(values)
      }
    }
    
    line_data['CH'] = [];
    for (var week of weeks) {
      var values = {}
      values['week'] = week;
      if (sum_corona_data[week]) {
        values['deceased'] = sum_corona_data[week]['deceased']
        values['tested']   = sum_corona_data[week]['tested']
        values['positive'] = sum_corona_data[week]['positive']
        values['vent']     = sum_corona_data[week]['vent']
      } else {
        values['deceased'] = 0
        values['tested']   = 0
        values['positive'] = 0
        values['vent']     = 0
      }
      line_data['CH'].push(values)
    }
  }

  for (var region of regions) {

    x.domain(d3.range(1, 53));
    y.domain([0, d3.max(sum_data[region]) + d3.max(sum_data[region])*0.2 ]).nice();
    //y.domain([0, 8000]);
    z.domain(ages);

    var div = d3.select("body.d3-graph")
      .append("div")
      .attr("width", divWidth)
      .attr("height", divHeight)
      .attr("id", region)
      .attr("class", "div-" + region)
      .attr("style", "margin: 50px")

    //var svg = d3.select("div.div-" + region)
    var svg = div.append("svg")
      .attr("width", width)
      .attr("height", height)
      .attr("class", "svg-" + region)
      .attr("viewBox", "0 0 " + divWidth  + " " + divHeight)

    var g = svg.append("g")
      .attr("transform", "translate(" + margin.left + "," + margin.top + ")")
      .attr("class", "g-" + region);

    //var g = d3.select("g.g-" + region)

    g.append("text")
      .attr("x", 30)
      .attr("y", 00)
      .attr("dy", "0.71em")
      .attr("fill", "#000")
      .text(geoshort[region] + " " + year)
      .attr("font-family", "sans-serif")
      .style("fill", "#000000");

    g.selectAll("g")
      .data(d3.stack().keys(ages)(chart_data[region]))
      .join("g")
      .attr("fill", function(d) { return z(d.key); })
      .selectAll("rect")
      .data(function(d) { return d; })
      .join("rect")
      .attr("x", function(d) { return x(d.data['week']); })
      .attr("y", function(d) { return y(d[1]); })
      .attr("height", function(d) { return y(d[0]) - y(d[1]); })
      .attr("width", x.bandwidth())
      .on("mouseover", function() { tooltip.style("display", null); })
      .on("mouseout", function() { tooltip.style("display", "none"); })
      .on("mousemove", function(d) {
        var xPosition = d3.mouse(this)[0] - 5;
        var yPosition = d3.mouse(this)[1] - 5;
        tooltip.attr("transform", "translate(" + xPosition + "," + yPosition + ")");
        tooltip.select("text").text(d[1]-d[0]);
      });

    if (cum_data['corona_data'][year]) {
      g.append('path')
        .datum(line_data[region])
        .attr("fill", "none")
        .attr("stroke", "red")
        .attr("stroke-width", 3.0)
        .attr("d", d3.line()
          .curve(d3.curveCatmullRom.alpha(0.5))
          //.curve(d3.curveCardinal.tension(0))
          .x(function(d) { return x(d['week']) + x.bandwidth()/2 })
          .y(function(d) { return y(d['deceased']) })
          )
      g.append('path')
        .datum(line_data[region])
        .attr("fill", "none")
        .attr("stroke", "blue")
        .attr("stroke-width", 3.0)
        .attr("d", d3.line()
          .curve(d3.curveCatmullRom.alpha(0.5))
          //.curve(d3.curveCardinal.tension(0))
          .x(function(d) { return x(d['week']) + x.bandwidth()/2 })
          .y(function(d) { return y(d['vent']) })
          )
    }

    g.append("g")
      .attr("class", "axis")
      .attr("transform", "translate(0," + height + ")")
      .call(d3.axisBottom(x))
      .selectAll("text")
      .style("text-anchor", "end")
      .attr("dx", "-.8em")
      .attr("dy", ".15em")
      .attr("transform", "rotate(-65)");

    g.append("g")
      .attr("class", "axis")
      .call(d3.axisLeft(y).ticks(null, "s"))
      .append("text")
      .attr("x", 2)
      .attr("y", y(y.ticks().pop()) + 0.5)
      .attr("dy", "0.32em")
      .attr("fill", "#000")
      .attr("font-weight", "bold")
      .attr("text-anchor", "start");

    var legend = g.append("g")
      .attr("font-family", "sans-serif")
      .attr("font-size", 10)
      .attr("text-anchor", "end")
      .selectAll("g")
      .data(ages.slice().reverse())
      .enter().append("g")
      .attr("transform", function(d, i) { return "translate(0," + i * 20 + ")"; });

    legend.append("rect")
      .attr("x", width - 19)
      .attr("width", 19)
      .attr("height", 19)
      .attr("fill", z);

    legend.append("text")
      .attr("x", width - 30)
      .attr("y", 9.5)
      .attr("dy", "0.32em")
      .text(function(d) { return d; });

    // Prep the tooltip bits, initial display is hidden
    var tooltip = svg.append("g")
      .attr("class", "tooltip-" + region)
      .style("display", "none")

    tooltip.append("rect")
      .attr("width", 60)
      .attr("height", 20)
      .attr("fill", "white")
      .style("opacity", 0.5);

    tooltip.append("text")
      .attr("x", 30)
      .attr("dy", "1.2em")
      .style("text-anchor", "middle")
      .attr("font-size", "12px")
      .attr("font-weight", "bold");

  };
};

const load_corona = async () => {

  var corona_data = {};

  raw = await load_data('data/swiss_covid19.csv');

  var dsv = d3.dsvFormat(',');
  var data = dsv.parse(raw);

  data.forEach(function(d) {
    var absolute_date = parseDay(d['date']);
    d['TIME_PERIOD']  = absolute_date;
    d['YEAR']         = year_formater(new Date(absolute_date))
    d['WEEK']         = parseInt(week_formater(new Date(absolute_date)));
  });

  corona_data['year']        = d3.map(data, function(d){return(d['YEAR'])}).keys()
  corona_data['week']        = d3.map(data, function(d){return(d['WEEK'])}).keys()
  corona_data['geo']         = d3.map(data, function(d){return(d['abbreviation_canton_and_fl'])}).keys()
  corona_data['timePeriod']  = d3.map(data, function(d){return d['TIME_PERIOD']}).keys()

  corona_data['geo'] = corona_data['geo'].filter((value)=>value!='FL');
  
  corona_data['year'].map((value0, index0) => {
    corona_data[value0] = {}
    corona_data['geo'].map((value1, index1) => {
      corona_data[value0][value1] = {}
      corona_data['week'].map((value2, index2) => {
        corona_data[value0][value1][value2] = {};
        corona_data[value0][value1][value2]['deceased'] = 0;
        corona_data[value0][value1][value2]['tested'] = 0;
        corona_data[value0][value1][value2]['positive'] = 0;
        corona_data[value0][value1][value2]['icu'] = 0;
        corona_data[value0][value1][value2]['vent'] = [];
      });
    });
  });
  
  for (var i = 0; i < data.length; i++) {
    if (data[i]['abbreviation_canton_and_fl'] == "FL") {
      continue;
    }
    if (data[i]['ncumul_deceased'] != "" && data[i]['ncumul_deceased'] > corona_data[data[i]['YEAR']][data[i]['abbreviation_canton_and_fl']][data[i]['WEEK']]['deceased']) {
      corona_data[data[i]['YEAR']][data[i]['abbreviation_canton_and_fl']][data[i]['WEEK']]['deceased'] = parseInt(data[i]['ncumul_deceased'])
    }
    if (data[i]['ncumul_tested'] != "" && data[i]['ncumul_tested'] > corona_data[data[i]['YEAR']][data[i]['abbreviation_canton_and_fl']][data[i]['WEEK']]['tested']) {
      corona_data[data[i]['YEAR']][data[i]['abbreviation_canton_and_fl']][data[i]['WEEK']]['tested'] = parseInt(data[i]['ncumul_tested'])
    }
    if (data[i]['ncumul_conf'] != "" && data[i]['ncumul_conf'] > corona_data[data[i]['YEAR']][data[i]['abbreviation_canton_and_fl']][data[i]['WEEK']]['positive']) {
      corona_data[data[i]['YEAR']][data[i]['abbreviation_canton_and_fl']][data[i]['WEEK']]['positive'] = parseInt(data[i]['ncumul_conf'])
    }
    if (data[i]['current_icu'] != "" && data[i]['current_icu'] > corona_data[data[i]['YEAR']][data[i]['abbreviation_canton_and_fl']][data[i]['WEEK']]['icu']) {
      corona_data[data[i]['YEAR']][data[i]['abbreviation_canton_and_fl']][data[i]['WEEK']]['icu'] = parseInt(data[i]['current_icu'])
    }
    if (data[i]['current_vent'] != "" && data[i]['current_vent'] > corona_data[data[i]['YEAR']][data[i]['abbreviation_canton_and_fl']][data[i]['WEEK']]['vent']) {
      corona_data[data[i]['YEAR']][data[i]['abbreviation_canton_and_fl']][data[i]['WEEK']]['vent'].push(parseInt(data[i]['current_vent']))
    }
  };

  return Promise.resolve(corona_data);

}

const load_death = async (year) => {

  var death_data = {};

  raw = await load_data('data/swiss_death_' + year + '.csv');

  var dsv = d3.dsvFormat(';');
  var data = dsv.parse(raw);

  data.forEach(function(d) {
    var year_week     = d['TIME_PERIOD'].slice(0,4) + "-" + parseInt(d['TIME_PERIOD'].slice(6));
    var absolute_date = parseWeek(year_week);
    d['TIME_PERIOD']  = absolute_date;
    d['YEAR']         = year_formater(new Date(absolute_date));
    d['WEEK']         = parseInt(week_formater(new Date(absolute_date)));
    d['GEO']          = geolong[d['GEO']];
  });

  death_data['year']        = d3.map(data, function(d){return d['YEAR']}).keys()
  death_data['week']        = d3.map(data, function(d){return d['WEEK']}).keys()
  death_data['geo']         = d3.map(data, function(d){return d['GEO']}).keys()
  death_data['timePeriod']  = d3.map(data, function(d){return d['TIME_PERIOD']}).keys()
  death_data['age']         = d3.map(data, function(d){return d['AGE']}).keys()
  death_data['sex']         = d3.map(data, function(d){return d['SEX']}).keys()

  death_data['age'].splice( death_data['age'].indexOf('_T'), 1 );

  death_data['geo'].map((value1, index1) => {
    death_data[value1] = {}
    death_data['week'].map((value2, index2) => {
      death_data[value1][value2] = {}
      death_data['age'].map((value3, index3) => {
        death_data[value1][value2][value3] = {}
        death_data['sex'].map((value4, index4) => {
          death_data[value1][value2][value3][value4] = 0
        });
      });
    });
  });

  for (var i = 0; i < data.length; i++) {
    if (data[i]['AGE'] != "_T") {
      death_data[data[i]['GEO']][data[i]['WEEK']][data[i]['AGE']][data[i]['SEX']] = parseInt(data[i]['Obs_value'])
    }
  }

  return Promise.resolve(death_data);

};

async function load_data(file) {
  const data = await d3.text(file);
  return data;
}

const init = async (year) => {

  for (var region of regions) {

    var div = d3.select("body.d3-graph")
      .append("div")
      .attr("width", divWidth)
      .attr("height", divHeight)
      .attr("class", "div-" + region)
      .attr("style", "margin: 50px")

    //var svg = d3.select("div.div-" + region)
    var svg = div.append("svg")
      .attr("width", width)
      .attr("height", height)
      .attr("class", "svg-" + region)
      .attr("viewBox", "0 0 " + divWidth  + " " + divHeight)

    var g = svg.append("g")
      .attr("transform", "translate(" + margin.left + "," + margin.top + ")")
      .attr("class", "g-" + region);

    //var g = d3.select("g.g-" + region)

    g.append("text")
      .attr("x", 30)
      .attr("y", 00)
    var div = d3.select("body.d3-graph")
      .append("div")
      .attr("width", divWidth)
      .attr("height", divHeight)
      .attr("class", "div-" + region)
      .attr("style", "margin: 50px")

  }

}

const build = async (year) => {
  //await init(year)
  await graph(year);
}

build(2020);

