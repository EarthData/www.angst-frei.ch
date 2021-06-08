require 'nokogiri'
require 'open-uri'

numbers = Array(1..105)

numbers.each do |number|

  url = "https://www.younggloballeaders.org/community?utf8=%E2%9C%93&page=#{number}"
  html = URI.open(url, "Accept-Encoding" => "plain") 
  doc = Nokogiri::HTML(html)


  persons = doc.css(".person")
  persons.each do |person|
    name = person.css(".person-name").text
    begin 
      name.encode!('Windows-1252', 'UTF-8')
    rescue
      puts "Conversion Error"
    end
    meta = person.css(".person-meta").text.strip
    begin 
      meta.encode!('Windows-1252', 'UTF-8')
    rescue
      puts "Conversion Error"
    end
    #bio = person.css(".person-bio").text.strip
    #puts bio
    puts "\"#{name}\",\"#{meta}\""
  end 

end
  
