require 'nokogiri'
require 'open-uri'
require 'pdfkit'
require 'gastly'

class Scraper

  #url = "https://schweizerzeit.ch/absurde-corona-strafen/"
  def scrape_url(url, date) 

    domain = URI(url).hostname.split('.').last(2).first
    tld = URI(url).hostname.split('.').last.upcase

    filedesc = url.split('/').last 
    html = URI.open(url) 
    doc = Nokogiri::HTML(html)

    # sitename
    if doc.at("meta[property='og:site_name']")
      site_name = doc.at("meta[property='og:site_name']")['content']
    else
      site_name = domain
    end

    # description
    if doc.at("meta[name='description']")
      description = doc.at("meta[name='description']")['content']
    elsif doc.at("meta[property='og:description']")
      description = doc.at("meta[property='og:description']")['content']
    else 
      description = ""
    end

    # date

#    doc.css('div.article-meta').each do |line|
#      
#      clean_line =  line.xpath("text()").to_s.strip
#      begin
#        puts clean_line
#        date = DateTime.parse(clean_line)
#        puts date
#      rescue Exception
#        puts "not a date"
#        date = Time.now - 86400
#      end
#    end

    if doc.at("meta[name='publish-date']")
      published_time = doc.at("meta[name='publish-date']")['content']
    elsif doc.at("meta[property='article:published_time']")
      published_time = doc.at("meta[property='article:published_time']")['content']
    elsif date
      published_time = date
    else 
      puts "no date found"
      exit 1
    end

    published_date = DateTime.parse(published_time)
    date  = published_date.strftime("%Y-%m-%d")

    title = doc.xpath("/html/body//h1").first.text

    filename = date + "-" + domain + "_" + filedesc
    File.write("#{filename}.md", "---\ndate:          " + date + "\nredirect:      " + url + "\ntitle:         " + site_name + "\nsubtitle:      '" + title + "'\ncountry:       " + tld + "\ncategories:    []\ntags:          [" + domain.downcase + "]\n---\n")

    #  pdf
    #kit = PDFKit.new(url)
    #kit.to_file("#{filename}.pdf")

    # screeenshot
    #screenshot = Gastly.screenshot(url)
    #screenshot.browser_width = 1280 # Default: 1440px
    #screenshot.browser_height = 780 # Default: 900px
    #screenshot.timeout = 1000 # Default: 0 seconds
    #screenshot.phantomjs_options = '--ignore-ssl-errors=true'
    #image = screenshot.capture
    #image.crop(width: 1280, height: 780, x: 0, y: 0) # Crop with an offset
    ##image.resize(width: 1280, height: 780) # Creates a preview of the web page
    #image.format('png')
    #image.save("#{filename}.png")

  end

end

url = ARGV[0]
date = ARGV[1]

puts "Scraping #{url} ..."
scrape = Scraper.new
scrape.scrape_url(url, date)
