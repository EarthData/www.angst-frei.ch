
require 'open-uri'
require 'yaml'

class String
  def strip_control_characters()
    chars.each_with_object("") do |char, str|
      str << char unless char.ascii_only? and (char.ord < 32 or char.ord == 127)
    end
  end
 
  def strip_control_and_extended_characters()
    chars.each_with_object("") do |char, str|
      str << char if char.ascii_only? and char.ord.between?(32,126)
    end
  end
end

class Tools

  def valid_json?(json)
    JSON.parse(json)
    return true
  rescue JSON::ParserError => e
    return false
  end

  def get_filename(url, domain, debug)

    config = YAML.load_file("config.yml")

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
    elsif config['article'][domain] == "pprevious"
      document = clean_url.split('/')[clean_url.split('/').length - 3]
    elsif config['article'][domain] == "cMeta"
      parameters = URI(url).query.split('&')
      parameters.each do |parameter|
        if parameter.match(/^cMeta=/)
          document = parameter.split('=')
        end
      end
    elsif config['article'][domain] == "page"
      document = clean_url.split('/').last.split("=")[1]
    end

    if config['filename'][domain] != "ignoredowncase"
      document.downcase!
    end

    return document

  end

  def get_sitename(url, debug)

    config = YAML.load_file("config.yml")

    uri = URI(url).hostname
    puts "URI: #{uri}" if debug

    if config['uri'][uri] and  config['uri'][uri] == "first"
      domain = URI(url).hostname.split('.').first
    elsif config['uri'][uri] and  config['uri'][uri] == "second"
      domain = URI(url).hostname.split('.')[1]
    else
      domain = URI(url).hostname.split('.').last(2).first
    end
    puts "Domain: #{domain}" if debug

    return domain

  end

  def write_file(site_data, warn_on_existing, file_data)

    if(File.exist?("../_posts/#{site_data['filename']}.md") and warn_on_existing)
      puts "File ../_posts/#{site_data['filename']}.md already exists"
      exit 0
    end
    tags = site_data['tags'].join(', ')
    categories = site_data['categories'].join(', ')
    persons = site_data['persons'].join(', ') if site_data['persons']

    content = %{---
date:          #{site_data['date']}
}
    if site_data['content'] == ''
      content += %{redirect:      #{site_data['redirect']}
}
    end
    content += %{title:         #{site_data['title']}
subtitle:      '#{site_data['subtitle']}'
}
    if site_data['description'] and site_data['content'] == ''
      content += %{description:   '#{site_data['description']}'
}
    end
    content += %{country:       #{site_data['country']}
}
    if site_data['timeline'] 
      content += %{timeline:      #{site_data['timeline']}
}
    end
    if persons 
      content += %{persons:       [#{persons}]
}
    end

    content += %{categories:    [#{categories}]
tags:          [#{tags}]
---
}

    if file_data
      content += file_data
    end

    if  site_data['content'] != ''
      content += site_data['content']
    end

    if warn_on_existing
      puts "Writing: #{site_data['filename']}.md\n#{content}"
    end

    File.write("#{site_data['filename']}.md", content)

    if !warn_on_existing
      file_diff1 = YAML.load_file("#{site_data['filename']}.md")
      file_diff2 = YAML.load_file("../_posts/#{site_data['filename']}.md")
      if file_diff1 == file_diff2
        #puts "Files #{site_data['filename']}.md are identical, deleting local copy"
        File.delete("#{site_data['filename']}.md")
      else
        puts "Diff:"
        puts file_diff1.to_a - file_diff2.to_a
        puts file_diff2.to_a - file_diff1.to_a
      end
    end
  end
end
