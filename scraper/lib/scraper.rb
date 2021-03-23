require 'nokogiri'
require 'open-uri'
require 'yaml'

class Scraper

  def scrape_url(url, date) 

    config = YAML.load_file("config.yml")

    domain = URI(url).hostname.split('.').last(2).first
    puts "Domain: #{domain}"
    tld = URI(url).hostname.split('.').last.upcase
    puts "TLD: #{tld}"

    if !config['cleanurl'][domain] 
      clean_url = url
    else
      clean_url = url.split('?')[url.split('?').length - 2]
    end

    file = clean_url.split('/').last
    document = File.basename(file,File.extname(file))

    if config['article'][domain] == "last"
      document = document.split('-').last
    elsif config['article'][domain] == "last_"
      document = document.split('_').last
    elsif config['article'][domain] == "lastdot"
      document = clean_url.split('.').last
    elsif config['article'][domain] == "lastcomma"
      document = document.split(',').last
    elsif config['article'][domain] == "first"
      document = document.split('-').first
    elsif config['article'][domain] == "previous"
      document = clean_url.split('/')[clean_url.split('/').length - 2]
    elsif config['article'][domain] == "page"
      document = clean_url.split('/').last.split("=")[1]
    end

    puts "filename: #{document}"

    html = URI.open(url) 
    doc = Nokogiri::HTML(html)

    # sitename
    if config['sitename'][domain]
      site_name = config['sitename'][domain]
      puts "Site Name: #{site_name} (config)"
    elsif doc.at("meta[property='og:site_name']")
      site_name = doc.at("meta[property='og:site_name']")['content'].to_s.strip
      puts "Site Name: #{site_name} (og)"
    else
      site_name = domain
      puts "Site Name: #{site_name} (domain)"
    end

    # description
    if doc.at("meta[name='description']")
      description = doc.at("meta[name='description']")['content'].to_s.strip
      puts "Description: #{description} (meta)"
    elsif doc.at("meta[property='og:description']")
      description = doc.at("meta[property='og:description']")['content'].to_s.strip
      puts "Description: #{description} (og)"
    else 
      description = ""
      puts "Description not found"
    end

    # date
    if date
      published_time = date
    elsif doc.at("meta[name='publish-date']")
      published_time = doc.at("meta[name='publish-date']")['content'].to_s.strip
      puts "Date: #{published_time} (meta publish-date)"
    elsif doc.at("meta[name='date']")
      published_time = doc.at("meta[name='date']")['content'].to_s.strip
      puts "Date: #{published_time} (meta date)"
    elsif doc.at("meta[property='article:published_time']")
      published_time = doc.at("meta[property='article:published_time']")['content'].to_s.strip
      puts "Date: #{published_time} (meta article:published_time)"
    else 
      puts "no date found"
      exit 1
    end

    if config['tag'][domain]
      tag = config['tag'][domain]
    else
      tag = site_name.downcase
    end
 
    published_date = DateTime.parse(published_time)
    date  = published_date.strftime("%Y-%m-%d")

    filename = date + "-" + domain + "_" + document

    # subtitle
    if doc.at("meta[property='og:title']") and config['subtitle'][domain] and config['subtitle'][domain] != "ignore-og"
      subtitle = doc.at("meta[property='og:title']")['content'].to_s.strip
      puts "Title: :#{subtitle}: (meta og:title)"
    elsif doc.at("meta[property='og:title']")
      subtitle = doc.at("meta[property='og:title']")['content'].to_s.strip
      puts "Title: :#{subtitle}: (meta og:title)"
    elsif doc.xpath("/html/body//h1")
      subtitle = doc.xpath("/html/body//h1").first.text.strip.chomp
      puts "Title: :#{subtitle}: (first h1)"
    else
      puts "no title found"
      exit 1
    end

    if config['subtitle'][domain] && config['subtitle'][domain] = 'last'
      subtitle.gsub!(/[\s]+[|-][\s]+.*$/, "")
      puts "Change title to: #{subtitle}"
    end

    #title = '' if not (title.force_encoding("UTF-8").valid_encoding?)
    #title = title.chars.select(&:valid_encoding?).join
    #puts "Title: :" + title.delete!("^\u{0000}-\u{007F}") + ":"
    #puts "Title: :" + title.strip_control_characters + ":"
    #puts "Title: :" + title.strip_control_and_extended_characters + ":"

    site_data = Hash.new
    site_data['date'] = date
    site_data['redirect'] = url
    site_data['title'] = site_name
    site_data['subtitle'] = subtitle
    site_data['country'] = tld
    site_data['tag'] = tag
    site_data['filename'] = filename
 
    return site_data

  end
end
