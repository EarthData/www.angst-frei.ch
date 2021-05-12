require 'pdfkit'
require 'gastly'

class Archive

  def pdf(url, filename) 
    #  pdf
    kit = PDFKit.new(url)
    kit.to_file("../assets/files/websites/#{filename}.pdf")
  end

  def screenshot(url, path, filename)
    # screeenshot
    screenshot = Gastly.screenshot(url)
    screenshot.browser_width = 1280 # Default: 1440px
    screenshot.browser_height = 780 # Default: 900px
    screenshot.timeout = 1000 # Default: 0 seconds
    screenshot.phantomjs_options = '--ignore-ssl-errors=true'
    image = screenshot.capture
    image.crop(width: 1280, height: 780, x: 0, y: 0) # Crop with an offset
    #image.resize(width: 1280, height: 780) # Creates a preview of the web page
    image.format('png')
    image.save("#{filename}.png")
  end

end

