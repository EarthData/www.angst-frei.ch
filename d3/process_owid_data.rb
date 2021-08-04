#!/usr/bin/env ruby

require 'csv'

def process_year(year)


  geo_names = ["CH","AU","IN","IS","DE","US","UK"]

  weeks = Array(1..53)

  data = Hash.new

  geo_names.each do |geo|
    data[geo.to_sym] = Hash[weeks.map{ |key| [key.to_s.to_sym, Hash[ages.map{ |key| [key.to_sym, 0] }]] }]
  end

  CSV.foreach("data_owid/owid-covid-data.csv",{quote_char: '"', col_sep: ";", encoding: "bom|utf-8", headers: true, header_converters: :symbol, converters: :all} ) do |row|
   
    geo = geo_short[row[:geo].to_sym]
    age = row[:age]
    (year,week) = row[:time_period].split(/\-W/)
    if row[:sex] == "T" and age != "_T"
      data[geo.to_sym][week.to_i.to_s.to_sym][age.to_sym] = row[:obs_value]
    end
  end

  header           = "week,".concat(ages.join(","))
  header_young     = "week,Y0T4,Y5T9,Y10T14,Y15T19,Y20T24,Y25T29,Y30T34,Y35T39,Y40T44,Y45T49"
  header_old       = "week,Y50T54,Y55T59,Y60T64,Y65T69,Y70T74,Y75T79,Y80T84,Y85T89,Y_GE90"
  header_all_young = "year,week,Y0T4,Y5T9,Y10T14,Y15T19,Y20T24,Y25T29,Y30T34,Y35T39,Y40T44,Y45T49"
  header_all_old   = "year,week,Y50T54,Y55T59,Y60T64,Y65T69,Y70T74,Y75T79,Y80T84,Y85T89,Y_GE90"

  File.new("data_processed/death_#{year}.csv", 'w')
  open("data_processed/death_#{year}.csv", 'w') do |f|
    f.puts header
    data[:CH].each do |week, values|
      f.puts "#{week},#{values[:Y0T4]},#{values[:Y5T9]},#{values[:Y10T14]},#{values[:Y15T19]},#{values[:Y20T24]},#{values[:Y25T29]},#{values[:Y30T34]},#{values[:Y35T39]},#{values[:Y40T44]},#{values[:Y45T49]},#{values[:Y50T54]},#{values[:Y55T59]},#{values[:Y60T64]},#{values[:Y65T69]},#{values[:Y70T74]},#{values[:Y75T79]},#{values[:Y80T84]},#{values[:Y85T89]},#{values[:Y_GE90]}"
    end
  end

  File.new("data_processed/death_#{year}_young.csv", 'w')
  open("data_processed/death_#{year}_young.csv", 'w') do |f|
    f.puts header_young
    data[:CH].each do |week, values|
      f.puts "#{week},#{values[:Y0T4]},#{values[:Y5T9]},#{values[:Y10T14]},#{values[:Y15T19]},#{values[:Y20T24]},#{values[:Y25T29]},#{values[:Y30T34]},#{values[:Y35T39]},#{values[:Y40T44]},#{values[:Y45T49]},#{values[:Y50T54]},#{values[:Y55T59]},#{values[:Y60T64]}"
    end
  end

  File.new("data_processed/death_#{year}_old.csv", 'w')
  open("data_processed/death_#{year}_old.csv", 'w') do |f|
    f.puts header_old
    data[:CH].each do |week, values|
      f.puts "#{week},#{values[:Y65T69]},#{values[:Y70T74]},#{values[:Y75T79]},#{values[:Y80T84]},#{values[:Y85T89]},#{values[:Y_GE90]}"
    end
  end

  if !File.file?("data_processed/death_all_old.csv")
    File.new("data_processed/death_all_old.csv", 'w')
  end
  open("data_processed/death_all_old.csv", 'a') do |f|
    f.puts header_all_old
    data[:CH].each do |week, values|
      f.puts "#{year},#{week},#{values[:Y65T69]},#{values[:Y70T74]},#{values[:Y75T79]},#{values[:Y80T84]},#{values[:Y85T89]},#{values[:Y_GE90]}"
    end
  end

  if !File.file?("data_processed/death_all_young.csv")
    File.new("data_processed/death_all_young.csv", 'w')
  end
  open("data_processed/death_all_young.csv", 'a') do |f|
    f.puts header_all_young
    data[:CH].each do |week, values|
      f.puts "#{year},#{week},#{values[:Y65T69]},#{values[:Y70T74]},#{values[:Y75T79]},#{values[:Y80T84]},#{values[:Y85T89]},#{values[:Y_GE90]}"
    end
  end

end

File.delete("data_processed/death_all_old.csv") if File.exist?("data_processed/death_all_old.csv")
File.delete("data_processed/death_all_young.csv") if File.exist?("data_processed/death_all_young.csv")
["2015","2016","2017","2018","2019","2020","2021"].each do |year|
  process_year(year);
end
