#!/usr/bin/env ruby

require 'creek'

def process_year(year)

  months = Array(1..12)

  data = Hash.new

  creek = Creek::Book.new 'data_geburt/geburt_monat_2021.xlsx', with_headers: true

  creek.sheets.each do |sheet|

    sheet.rows.each do |row|
      puts row # => {"A1"=>"Content 1", "B1"=>nil, "C1"=>nil, "D1"=>"Content 3"}
    end

    puts sheet.state   # => 'visible'
    puts sheet.name    # => 'Sheet1'
    puts sheet.rid     # => 'rId2'

  end

  exit

  CSV.foreach("data_bag/swiss_death_#{year}.csv",{quote_char: '"', col_sep: ";", encoding: "bom|utf-8", headers: true, header_converters: :symbol, converters: :all} ) do |row|
   
    geo = geo_short[row[:geo].to_sym]
    age = row[:age]
    (year,week) = row[:time_period].split(/\-W/)
    if row[:sex] == "T" and age != "_T"
      data[geo.to_sym][week.to_i.to_s.to_sym][age.to_sym] = row[:obs_value]
    end
  end

  header           = "week,".concat(ages.join(","))
  header_young     = "week,Y0T4,Y5T9,Y10T14,Y15T19,Y20T24,Y25T29,Y30T34,Y35T39,Y40T44,Y45T49,Y50T54,Y55T59,Y60T64"
  header_old       = "week,Y65T69,Y70T74,Y75T79,Y80T84,Y85T89,Y_GE90"

  data.each do |geo, values|

    File.new("data_bag_processed/death_#{year}_#{geo}_young.csv", 'w')
    open("data_bag_processed/death_#{year}_#{geo}_young.csv", 'w') do |f|
      f.puts header_young
      data[geo.to_sym].each do |week, values|
        f.puts "#{week},#{values[:Y0T4]},#{values[:Y5T9]},#{values[:Y10T14]},#{values[:Y15T19]},#{values[:Y20T24]},#{values[:Y25T29]},#{values[:Y30T34]},#{values[:Y35T39]},#{values[:Y40T44]},#{values[:Y45T49]},#{values[:Y50T54]},#{values[:Y55T59]},#{values[:Y60T64]}"
      end
    end

    File.new("data_bag_processed/death_#{year}_#{geo}_old.csv", 'w')
    open("data_bag_processed/death_#{year}_#{geo}_old.csv", 'w') do |f|
      f.puts header_old
      data[geo.to_sym].each do |week, values|
        f.puts "#{week},#{values[:Y65T69]},#{values[:Y70T74]},#{values[:Y75T79]},#{values[:Y80T84]},#{values[:Y85T89]},#{values[:Y_GE90]}"
      end
    end

  end

end

["2015","2016","2017","2018","2019","2020","2021"].each do |year|
  process_year(year);
end
