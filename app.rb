require_relative 'lib/scraper.rb'
require_relative 'lib/formatter.rb'

# sc = Scraper.new
# sc.run()

fm = Formatter.new(JSON.parse(File.read('output.json')))
fm.run()