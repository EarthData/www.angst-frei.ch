const cum_data = d3.text("death.csv").then(function(raw) {

  var dsv = d3.dsvFormat(';');
  var data = dsv.parse(raw);
  var death_data = {};

  const geolong = {CH: "CH", CH011: "VD", CH012: "VS", CH013: "GE", CH021: "BE", CH022: "FR", CH023: "SO", CH024: "NE", CH025: "JU", CH031: "BS", CH032: "BL", CH033: "AG", CH040: "ZH", CH051: "GL", CH052: "SH", CH053: "AR", CH054: "AI", CH055: "SG", CH056: "GR", CH057: "TG", CH061: "LU", CH062: "UR", CH063: "SZ", CH064: "OW", CH065: "NW", CH066: "ZG", CH070: "TI"};

  data.forEach(function(d) {
      d['TIME_PERIOD'] = d['TIME_PERIOD'].slice(0,4) + "-" + parseInt(d['TIME_PERIOD'].slice(6));
      d['GEO'] = geolong[d['GEO']];
  });

  death_data['GEO']         = d3.map(data, function(d){return d['GEO'];}).keys()
  death_data['TIME_PERIOD'] = d3.map(data, function(d){return d['TIME_PERIOD'];}).keys()
  death_data['AGE']         = d3.map(data, function(d){return d['AGE'];}).keys()
  death_data['SEX']         = d3.map(data, function(d){return d['SEX'];}).keys()

  regionlist = death_data['GEO'];
  regionlist = regionlist.splice(1);
  regionlist.push('CH');
  death_data['GEO'] = regionlist;

  death_data['AGE'].splice( death_data['AGE'].indexOf('_T'), 1 );

  death_data['GEO'].map((value1, index1) => {
    death_data[value1] = {}
    death_data['TIME_PERIOD'].map((value2, index2) => {
      death_data[value1][value2] = {}
      death_data['AGE'].map((value3, index3) => {
        death_data[value1][value2][value3] = {}
        death_data['SEX'].map((value4, index4) => {
          death_data[value1][value2][value3][value4] = 0
        });
      });
    });
  });

  for (var i = 0; i < data.length; i++) {
    if (data[i]['AGE'] != "_T") {
      death_data[data[i]['GEO']][data[i]['TIME_PERIOD']][data[i]['AGE']][data[i]['SEX']] = parseInt(data[i]['Obs_value'])
    }
  }

  var cum_data = {};
  cum_data['death_data'] = death_data;
  return cum_data;

});

cum_data.then(async function(cum_data) {

  corona_data = {};
  corona_data['CH'] = {};
  data = await getCorona();

  for (var line of data) {
    var geo = line['abbreviation_canton_and_fl'];
    if (geo == "FL") {
      continue;
    }
    var week = moment(line['date']).isoWeek();
    var year = moment(line['date']).year();
    var act_ts = year + "-" + week;
    var last_ts = year + "-" + String(week-1);
    var ncumul_deceased = parseInt(line['ncumul_deceased'])
    var ncumul_tested = parseInt(line['ncumul_tested'])
    var current_hosp = parseInt(line['current_hosp'])

    corona_data[geo] = typeof(corona_data[geo]) == 'undefined' ? {} : corona_data[geo];
    corona_data[geo][act_ts] = typeof(corona_data[geo][act_ts]) == 'undefined' ? {} : corona_data[geo][act_ts];
    corona_data[geo][act_ts]['deceased'] =  ncumul_deceased;
      
    if (isNaN(corona_data[geo][act_ts]['deceased']) && typeof corona_data[geo][last_ts] !== "undefined" && !isNaN(corona_data[geo][last_ts]['deceased'])) {
      corona_data[geo][act_ts]['deceased'] = corona_data[geo][last_ts]['deceased']
    } else if (isNaN(corona_data[geo][act_ts]['deceased'])) {
      corona_data[geo][act_ts]['deceased'] = 0;
    }
  }

  cum_data['corona_data'] = corona_data;
  return cum_data;

}).then(async function(cum_data) {
  
  var death_data = cum_data['death_data']
  var corona_data = cum_data['corona_data']

  var region_data = {};
  for (var geo of death_data['GEO']) {
    region_data[geo] = [];
    for (var act_ts in death_data[geo]) {
      var values = {} 
      var week = act_ts.slice(5);
      var year = act_ts.slice(0,4);
      var last_ts = year + "-" + String(week-1);
      values['TimePeriod'] = "W" + week;
      for (var age in death_data[geo][act_ts]) {
        values[age] = death_data[geo][act_ts][age]['T']
      };
      if (geo != 'CH') {
        if (typeof corona_data[geo] !== "undefined" && typeof corona_data[geo][act_ts] !== "undefined") {
          if (typeof corona_data[geo][last_ts] !== "undefined") {
            values['Corona'] = corona_data[geo][act_ts]['deceased'] - corona_data[geo][last_ts]['deceased'];
          } else {
            values['Corona'] = corona_data[geo][act_ts]['deceased']
          }
        } else {
          values['Corona'] = 0;
        }
      } else {
        values['Corona'] = corona_data[geo][act_ts]['deceased']
      }
      if (geo != 'CH') {
        if (typeof(corona_data['CH'][act_ts]) == 'undefined') {
          corona_data['CH'][act_ts] = {};
          corona_data['CH'][act_ts]['deceased'] = 0;
        } 
        corona_data['CH'][act_ts]['deceased'] += values['Corona'];
      }
      region_data[geo].push(values)
      if (values['Corona'] < 0) {
        console.log(geo);
        console.log(act_ts);
        console.log(last_ts);
      }
    };   
  };

  const geoshort = {CH: "Switzerland", VD: "Vaud", VS: "Valais", GE: "Genève", BE: "Bern", FR: "Freiburg", SO: "Solothurn", NE: "Neuchâtel", JU: "Jura", BS: "Basel-Stadt", BL: "Basel-Landschaft", AG: "Aargau", ZH: "Zürich", GL: "Glarus", SH: "Schaffhausen", AR: "Appenzell Ausserrhoden", AI: "Appenzell Innerrhoden", SG: "St. Gallen", GR: "Graubünden", TG: "Thurgau", LU: "Luzern", UR: "Uri", SZ: "Schwyz", OW: "Obwalden", NW: "Nidwalden", ZG: "Zug", TI: "Ticino"};

  const keys = ['Y0T4', 'Y5T9', 'Y10T14', 'Y15T19', 'Y20T24', 'Y25T29', 'Y30T34', 'Y35T39', 'Y40T44', 'Y45T49', 'Y50T54', 'Y55T59', 'Y60T64', 'Y65T69', 'Y70T74', 'Y75T79', 'Y80T84', 'Y85T89', 'Y_GE90', 'Corona']

  const groupKey = "TimePeriod"

  var divWidth = 2000;
  var divHeight = 800;
  var margin = {top: 10, right: 5, bottom: 20, left: 5}
    width = divWidth - margin.left - margin.right,
    height = divHeight - margin.top - margin.bottom;

  Object.keys(region_data).sort().forEach(function(region) {

    var data = region_data[region];

    x0 = d3.scaleBand()
      .domain(data.map(d => d[groupKey]))
      .rangeRound([margin.left, width - margin.right])
      .paddingInner(0.1)

    x1 = d3.scaleBand()
      .domain(keys)
      .rangeRound([0, x0.bandwidth()])
      .padding(0.05)

    y = d3.scaleLinear()
      .domain([0, d3.max(data, d => d3.max(keys, key => d[key]))]).nice()
      .rangeRound([height - margin.bottom, margin.top])

    color = d3.scaleOrdinal()
      .range(['#e6194B', '#3cb44b', '#ffe119', '#4363d8', '#f58231', '#911eb4', '#42d4f4', '#f032e6', '#bfef45', '#fabed4', '#469990', '#dcbeff', '#9A6324', '#fffac8', '#800000', '#aaffc3', '#808000', '#ffd8b1', '#000075', '#000000']);
      //.range(['#e6194B', '#3cb44b', '#ffe119', '#4363d8', '#f58231', '#911eb4', '#42d4f4', '#f032e6', '#bfef45', '#fabed4', '#469990', '#dcbeff', '#9A6324', '#fffac8', '#800000', '#aaffc3', '#808000', '#ffd8b1', '#000075', '#a9a9a9', '#000000']);

    xAxis = g => g
      .attr("transform", `translate(0,${height - margin.bottom})`)
      .call(d3.axisBottom(x0).tickSizeOuter(0))
      .call(g => g.select(".domain").remove())

    yAxis = g => g
      .attr("transform", `translate(${margin.left},0)`)
      .call(d3.axisLeft(y).ticks(null, "s"))
      .call(g => g.select(".domain").remove())
      .call(g => g.select(".tick:last-of-type text").clone()
        .attr("x", 3)
        .attr("text-anchor", "start")
        .attr("font-weight", "bold")
        .text(data.y))

    legend = svg => {
      const g = svg
        .attr("transform", `translate(${width},0)`)
        .attr("text-anchor", "end")
        .attr("font-family", "sans-serif")
        .attr("font-size", 10)
        .selectAll("g")
        .data(color.domain().slice().reverse())
        .join("g")
        .attr("transform", (d, i) => `translate(0,${i * 20})`);

      g.append("rect")
        .attr("x", -19)
        .attr("width", 19)
        .attr("height", 19)
        .attr("fill", color);

      g.append("text")
        .attr("x", -24)
        .attr("y", 9.5)
        .attr("dy", "0.35em")
        .text(d => d);
    }

    var svg = d3.select("body")
      .append("div")
      .attr("width", divWidth)
      .attr("height", divHeight)
      .attr("id", region)
      .attr("style", "margin: 50px")
      .append("svg")
      .attr("width", width)
      .attr("height", height)
      .attr("viewBox", "0 0 " + divWidth  + " " + divHeight);

    svg.append("g")
      .selectAll("g")
      .data(data)
      .join("g")
      .attr("transform", d => `translate(${x0(d[groupKey])},0)`)
      .selectAll("rect")
      .data(d => keys.map(key => ({key, value: d[key]})))
      .join("rect")
      .attr("x", d => x1(d.key))
      .attr("y", d => y(d.value))
      .attr("width", x1.bandwidth())
      .attr("height", d => y(0) - y(d.value))
      .attr("fill", d => color(d.key));

    svg.append("g")
      .call(xAxis);

    svg.append("g")
      .call(yAxis);

    svg.append("g")
      .call(legend);

  });
});

async function getCorona() {
  const data = await d3.csv('corona.csv');
  //return Promise.resolve(data);
  return data;
}
