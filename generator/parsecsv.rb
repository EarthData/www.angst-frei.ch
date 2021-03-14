require 'csv'
require 'date'

table = CSV.parse(File.read("./rubikon2.csv"), headers: true)

table.each do |n|
  
  d = DateTime.parse(n['pubDate'])
  day  = d.strftime("%Y-%m-%d")
  link =  n['Link'].dup
  filename = day + "-Rubikon_" + n['Link'].sub!(/https:\/\/www\.rubikon\.news\/artikel\//, '') + ".md"
  
  File.write(filename, "---\ndate:       " + day + "\nredirect:   " + link + "\ntitle:      Rubikon\nsubtitle:   \"" + n['Title'] + "\"\ncategories: Medien\ntags:       [rubikon]\n---\n")

end
