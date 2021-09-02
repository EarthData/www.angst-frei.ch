#!/usr/bin/env ruby

require 'csv'

def process_data()

  geo_names = ["CH", "VD", "VS", "GE", "BE", "FR", "SO", "NE", "JU", "BS", "BL", "AG", "ZH", "GL", "SH", "AR", "AI", "SG", "GR", "TG", "LU", "UR", "SZ", "OW", "NW", "ZG", "TI"];

#  date_from  = Date.parse("#{year}-01-01")
#  date_to    = Date.parse("#{year}-12-31")
#  days       = (date_from..date_to).map(&:to_s)

  caps = ["covid19", "noncovid19", "free"]
  types = ["nonicu", "icu"]

  data = Hash.new

  geo_names.each do |geo|
    #data[geo.to_sym] = Hash[days.map{ |key| [key.to_s.to_sym, Hash[caps.map{ |key| [key.to_sym, Hash[types.map{ |key| [key.to_sym, 0]}]] }]] }]
    data[geo.to_sym] = Hash.new
  end

  CSV.foreach("data_hosp/COVID19HospCapacity_geoRegion.csv",{quote_char: '"', col_sep: ",", encoding: "bom|utf-8", headers: true, header_converters: :symbol, converters: :all} ) do |row|
   
    geo = row[:georegion]

    parsedData = Hash.new

    parsedData['icu'] = Hash.new
    parsedData['nonicu'] = Hash.new
    parsedData['total'] = Hash.new


    parsedData['icu']['covid19'] = row[:icu_covid19patients] == "NA" ? 0 : row[:icu_covid19patients].to_int
    parsedData['icu']['noncovid19'] = row[:icu_noncovid19patients] == "NA" ? 0 : row[:icu_noncovid19patients].to_int
    parsedData['icu']['capacity_data'] = row[:icu_capacity] == "NA" ? 0 : row[:icu_capacity].to_int
    parsedData['icu']['allpatients_data'] = row[:icu_allpatients] == "NA" ? 0 : row[:icu_allpatients].to_int
    parsedData['icu']['free'] = row[:icu_freecapacity] == "NA" ? 0 : row[:icu_freecapacity].to_int

    parsedData['total']['covid19'] = row[:total_covid19patients] == "NA" ? 0 : row[:total_covid19patients].to_int
    parsedData['total']['noncovid19'] = row[:total_noncovid19patients] == "NA" ? 0 : row[:total_noncovid19patients].to_int
    parsedData['total']['capacity_data'] = row[:total_capacity] == "NA" ? 0 : row[:total_capacity].to_int
    parsedData['total']['allpatients_data'] = row[:total_allpatients] == "NA" ? 0 : row[:total_allpatients].to_int
    parsedData['total']['free'] = row[:total_freecapacity] == "NA" ? 0 : row[:total_freecapacity].to_int

    parsedData['nonicu']['covid19'] = parsedData['total']['covid19'] - parsedData['icu']['covid19']
    parsedData['nonicu']['noncovid19'] = parsedData['total']['noncovid19'] - parsedData['icu']['noncovid19']
    parsedData['nonicu']['free'] = parsedData['total']['free'] - parsedData['icu']['free']

#    parsedData['icu_allpatients'] = parsedData['icu_covid19patients'] + parsedData['icu_noncovid19patients']
#    if parsedData['icu_allpatients'] != parsedData['icu_allpatients_data']
#      puts "icu_allpatients #{parsedData['icu_allpatients']} ne #{parsedData['icu_allpatients_data']}"  
#    end
#    icu_capacity = icu_allpatients + icu_freecapacity
#    if icu_capacity != icu_capacity_data
#      puts "icu_capacity: #{icu_capacity} ne #{icu_capacity_data}"  
#    end
#    total_allpatients = total_covid19patients + total_noncovid19patients
#    if total_allpatients != total_allpatients_data
#      puts "total_allpatients #{total_allpatients} ne #{total_allpatients_data}"  
#    end
#    total_capacity = total_allpatients + total_freecapacity
#    if total_capacity != total_capacity_data
#      puts "total_capacity: #{total_capacity} ne #{total_capacity_data}"  
#    end
    

#    ayear = row[:date].strftime('%Y').to_i
#    next if year < ayear or year > ayear
    aday = row[:date].strftime('%Y-%m-%d')

    unless data[geo.to_sym].has_key? aday.to_sym
      data[geo.to_sym][aday.to_sym] = Hash[types.map{ |key| [key.to_s.to_sym, Hash[caps.map{ |key| [key.to_sym,  0]}]] }]
    end

    types.each do |type|
      caps.each do |cap|
        data[geo.to_sym][aday.to_s.to_sym][type.to_sym][cap.to_sym] = parsedData[type][cap]
      end
    end
  end

  header           = "day,".concat(caps.join(","))

  geo_names.each do |geo|
    types.each do |type|
      File.new("data_hosp_processed/hosp_#{geo}-#{type}.csv", 'w')
      open("data_hosp_processed/hosp_#{geo}-#{type}.csv", 'w') do |f|
        f.puts header
        data[geo.to_sym].each do |day, values|
          f.puts "#{day},#{values[type.to_sym][:covid19]},#{values[type.to_sym][:noncovid19]},#{values[type.to_sym][:free]}"
        end
      end
    end
  end
end

process_data();
