#!/usr/bin/env ruby

require 'csv'

def process_year(year)


  geo_names = ["CHE","AUT","IND","ISL","DEU","USA","GBR","ISR"]
  weeks = Array(1..53)
  fields_of_interest = ["new_cases", "new_vaccinations", "new_deaths", "population"]

  data = Hash.new

  geo_names.each do |geo|
    data[geo.to_sym] = Hash[weeks.map{ |key| [("2021-W%02d" % [key]).to_s.to_sym, Hash[fields_of_interest.map{ |key| [key.to_sym, 0] }]] }]
  end

  CSV.foreach("data_owid/owid-covid-data.csv",{quote_char: '"', col_sep: ",", encoding: "bom|utf-8", headers: true, header_converters: :symbol, converters: :all} ) do |row|
   
    geo = row[:iso_code].to_sym
    date = row[:date].strftime('%G-W%V')
    year = row[:date].strftime('%G').to_i
    if data[geo] and year > 2020
      fields_of_interest.each do |value|
        data[geo][date.to_sym][value.to_sym] += row[:"#{value}"].to_f
        #puts "#{geo},#{week},#{row[:date]},#{value},#{row[:"#{value}"].to_f},#{data[geo][week.to_s.to_sym][value.to_sym]}"
      end
    end
  end

  header = "date,".concat(fields_of_interest.reject{ |k| k=="population" }.join(","))

  geo_names.each do |geo_name|
    File.new("data_owid_processed/data_owid_#{geo_name}.csv", 'w')
    open("data_owid_processed/data_owid_#{geo_name}.csv", 'w') do |f|
      f.puts header
      data[geo_name.to_sym].each do |date, values|
        new_cases = 0
        new_deaths = 0
        new_vaccinations = 0
        if values[:population] > 0 and values[:new_cases] > 0
          new_cases = (values[:new_cases] / values[:population] * 1000000).round
        end
        if values[:new_deaths] > 0
          new_deaths = values[:new_deaths]
        end
        if values[:population] > 0 and values[:new_vaccinations] > 0
          new_vaccinations = (values[:new_vaccinations] / values[:population] * 100000).round
        end
        f.puts "#{date},#{new_cases},#{new_vaccinations},#{new_deaths}"
      end
    end
  end

end

#File.delete("data_processed/death_all_old.csv") if File.exist?("data_processed/death_all_old.csv")
#File.delete("data_processed/death_all_young.csv") if File.exist?("data_processed/death_all_young.csv")
process_year(2021);
