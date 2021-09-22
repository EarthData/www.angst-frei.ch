#!/usr/bin/env ruby

require 'net/http'
require 'json'

url = 'https://www.covid19.admin.ch/api/data/context'
uri = URI(url)
response = Net::HTTP.get(uri)
json = JSON.parse(response)

#pp json

hospVaccPersons = json['sources']['individual']['csv']['weekly']['byAge']['hospVaccPersons']
hosp            = json['sources']['individual']['csv']['weekly']['byAge']['hosp']
hospCapacity    = json['sources']['individual']['csv']['daily']['hospCapacity']

[hospVaccPersons, hosp, hospCapacity].each do |url|
   uri = URI(url)
   response = Net::HTTP.get(uri)

   filename = url.split('/', -1)[-1]
   puts "processing #{url} ..." 

   file = File.new(filename, 'w')
   file.write(response)
   file.close     
end

