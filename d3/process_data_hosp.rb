#!/usr/bin/env ruby

require 'csv'

def process_data(year)

  geo_names = ["CHFL", "VD", "VS", "GE", "BE", "FR", "SO", "NE", "JU", "BS", "BL", "AG", "ZH", "GL", "SH", "AR", "AI", "SG", "GR", "TG", "LU", "UR", "SZ", "OW", "NW", "ZG", "TI"];

  weeknumber = Date.new(year, 12, 28).strftime('%-V')
  weeks = Array(1..weeknumber.to_i)

  ages = ["0 - 9", "10 - 19", "20 - 29", "30 - 39", "40 - 49", "50 - 59", "60 - 69", "70 - 79", "80+", "Unbekannt", "Total"]
  types = ["covid", "vacc_age"]

  data = Hash.new

  geo_names.each do |geo|
    data[geo.to_sym] = Hash[weeks.map{ |key| [key.to_s.to_sym, Hash[ages.map{ |key| [key.to_sym, Hash[types.map{ |key| [key.to_sym, 0]}]] }]] }]
  end

  data_vacc = Hash.new

  vacc_types = ["fully_vaccinated", "fully_vaccinated_first_booster", "fully_vaccinated_no_booster", "partially_vaccinated", "not_vaccinated", "unknown", "Total"]
  types = ["vacc_type"]

  geo_names.each do |geo|
    data_vacc[geo.to_sym] = Hash[weeks.map{ |key| [key.to_s.to_sym, Hash[vacc_types.map{ |key| [key.to_sym, Hash[types.map{ |key| [key.to_sym, 0]}]] }]] }]
  end

  CSV.foreach("data_hosp/COVID19Hosp_geoRegion_AKL10_w.csv",{quote_char: '"', col_sep: ",", encoding: "bom|utf-8", headers: true, header_converters: :symbol, converters: :all} ) do |row|
   
    next if ['CH01','CH02','CH03','CH04','CH05','CH06','CH07','CH','FL'].include?(row[:georegion])

    geo = row[:georegion]
    age = row[:altersklasse_covid19]
    current_week = Time.now.strftime('%-V')
    ayear = row[:datum].to_s[0,4].to_i
    week = row[:datum].to_s[4,2].to_i
    next if year < ayear or year > ayear

    data[geo.to_sym][week.to_s.to_sym][age.to_sym][:covid] = row[:entries]
    data[geo.to_sym][week.to_s.to_sym][:Total][:covid] += row[:entries]
  end

  CSV.foreach("data_hosp/COVID19Hosp_vaccpersons_AKL10_w.csv",{quote_char: '"', col_sep: ",", encoding: "bom|utf-8", headers: true, header_converters: :symbol, converters: :all} ) do |row|
   
    next if row[:georegion] == "CH01" or row[:georegion] == "CH02" or row[:altersklasse_covid19] == "all" or row[:vaccination_status].match(/^(not_vaccinated|unknown)$/)

    geo = row[:georegion]
    age = row[:altersklasse_covid19]
    current_week = Time.now.strftime('%-V')
    ayear = row[:date].to_s[0,4].to_i
    week = row[:date].to_s[4,2].to_i
    next if year < ayear or year > ayear

    #puts "adding #{row[:entries]} to #{geo} #{week} #{age} => #{data[geo.to_sym][week.to_s.to_sym][age.to_sym][:vacc]}"

    data[geo.to_sym][week.to_s.to_sym][age.to_sym][:vacc_age] += row[:entries]
    data[geo.to_sym][week.to_s.to_sym][:Total][:vacc_age] += row[:entries]
  end

  CSV.foreach("data_hosp/COVID19Hosp_vaccpersons_AKL10_w.csv",{quote_char: '"', col_sep: ",", encoding: "bom|utf-8", headers: true, header_converters: :symbol, converters: :all} ) do |row|
   
    next if row[:georegion] == "CH01" or row[:georegion] == "CH02" or row[:altersklasse_covid19] != "all"

    geo = row[:georegion]
    type = row[:vaccination_status]
    current_week = Time.now.strftime('%-V')
    ayear = row[:date].to_s[0,4].to_i
    week = row[:date].to_s[4,2].to_i
    next if year < ayear or year > ayear

    #puts "adding #{row[:entries]} to #{geo} #{week} #{age} => #{data[geo.to_sym][week.to_s.to_sym][age.to_sym][:vacc]}"
    #puts row[:vaccination_status]

    data_vacc[geo.to_sym][week.to_s.to_sym][type.to_sym][:vacc_type] += row[:entries]
    data_vacc[geo.to_sym][week.to_s.to_sym][:Total][:vacc_type] += row[:entries]
  end

  header = "week,0-9,10-19,20-29,30-39,40-49,50-59,60-69,70-79,80-"

  geo_names.each do |geo|
    ["covid","vacc_age"].each do |group|
      File.new("data_hosp_processed/hosp_#{year}-#{geo}-#{group}.csv", 'w')
      open("data_hosp_processed/hosp_#{year}-#{geo}-#{group}.csv", 'w') do |f|
        f.puts header
        data[geo.to_sym].each do |week, values|
          f.puts "#{week},#{values[:"0 - 9"][group.to_sym]},#{values[:"10 - 19"][group.to_sym]},#{values[:"20 - 29"][group.to_sym]},#{values[:"30 - 39"][group.to_sym]},#{values[:"40 - 49"][group.to_sym]},#{values[:"50 - 59"][group.to_sym]},#{values[:"60 - 69"][group.to_sym]},#{values[:"70 - 79"][group.to_sym]},#{values[:"80+"][group.to_sym]}"
        end
      end
    end
  end

  header = "week,,fully_vaccinated_first_booster,fully_vaccinated_no_booster,fully_vaccinated,partially_vaccinated,not_vaccinated,unknown"

  geo_names.each do |geo|
    ["vacc_type"].each do |group|
      File.new("data_hosp_processed/hosp_#{year}-#{geo}-#{group}.csv", 'w')
      open("data_hosp_processed/hosp_#{year}-#{geo}-#{group}.csv", 'w') do |f|
        f.puts header
        data_vacc[geo.to_sym].each do |week, values|
          f.puts "#{week},#{values[:fully_vaccinated_first_booster][:vacc_type]},#{values[:fully_vaccinated_no_booster][:vacc_type]},#{values[:fully_vaccinated][:vacc_type]},#{values[:partially_vaccinated][:vacc_type]},#{values[:not_vaccinated][:vacc_type]},#{values[:unknown][:vacc_type]}"
        end
      end
    end
  end
end

process_data(2020);
process_data(2021);
process_data(2022);
