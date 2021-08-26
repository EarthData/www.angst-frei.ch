#!/usr/bin/env ruby

require 'csv'

def process_data()

  geo_short = {CHFL: "CHFL", CH011: "VD", CH012: "VS", CH013: "GE", CH021: "BE", CH022: "FR", CH023: "SO", CH024: "NE", CH025: "JU", CH031: "BS", CH032: "BL", CH033: "AG", CH040: "ZH", CH051: "GL", CH052: "SH", CH053: "AR", CH054: "AI", CH055: "SG", CH056: "GR", CH057: "TG", CH061: "LU", CH062: "UR", CH063: "SZ", CH064: "OW", CH065: "NW", CH066: "ZG", CH070: "TI"};
  geo_names = geo_short.values

  weeks = Array(1..53)

  ages = ["0 - 9", "10 - 19", "20 - 29", "30 - 39", "40 - 49", "50 - 59", "60 - 69", "70 - 79", "80+", "Unbekannt", "Total"]

  types = ["covid", "vacc"]

  data = Hash.new

  geo_names.each do |geo|
    data[geo.to_sym] = Hash[weeks.map{ |key| [key.to_s.to_sym, Hash[ages.map{ |key| [key.to_sym, Hash[types.map{ |key| [key.to_sym, 0]}]] }]] }]
  end

  CSV.foreach("data_ch/COVID19Hosp_geoRegion_AKL10_w.csv",{quote_char: '"', col_sep: ",", encoding: "bom|utf-8", headers: true, header_converters: :symbol, converters: :all} ) do |row|
   
    next if row[:georegion] != "CHFL"

    geo = geo_short[row[:georegion].to_sym]
    age = row[:altersklasse_covid19]
    current_week = Time.now.strftime('%-V')
    year = row[:datum].to_s[0,4].to_i
    week = row[:datum].to_s[4,2].to_i
    next if year < 2021

    data[geo.to_sym][week.to_s.to_sym][age.to_sym][:covid] = row[:entries]
    data[geo.to_sym][week.to_s.to_sym][:Total][:covid] += row[:entries]
  end

  CSV.foreach("data_ch/COVID19Hosp_vaccpersons_AKL10_w.csv",{quote_char: '"', col_sep: ",", encoding: "bom|utf-8", headers: true, header_converters: :symbol, converters: :all} ) do |row|
   

    next if row[:georegion] != "CHFL"

    puts row

    geo = geo_short[row[:georegion].to_sym]
    age = row[:altersklasse_covid19]
    current_week = Time.now.strftime('%-V')
    year = row[:date].to_s[0,4].to_i
    week = row[:date].to_s[4,2].to_i
    next if year < 2021


    data[geo.to_sym][week.to_s.to_sym][age.to_sym][:vacc] = row[:entries]
    data[geo.to_sym][week.to_s.to_sym][:Total][:vacc] += row[:entries]
  end

  header           = "week,covid,vacc"

  File.new("data_ch_processed/hosp.csv", 'w')
  open("data_ch_processed/hosp.csv", 'w') do |f|
    f.puts header
    data[:CHFL].each do |week, values|
      puts week
      puts values
      f.puts "#{week},#{values[:Total][:covid]},#{values[:Total][:vacc]}"
    end
  end
end

process_data();
