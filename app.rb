require 'nokogiri'
require 'json'
require 'open-uri'
require 'net/http'
require 'pp'
require 'sequel'

DB = Sequel.connect('sqlite://knihyemilovi.db')

require_relative 'lib/AuthorModel.rb'
require_relative 'lib/BookModel.rb'
require_relative 'lib/Scraper.rb'
require_relative 'lib/DownloadWorker.rb'

def parse_author_and_title url
    filename =  url.split('/')[-1] + '.html'
    file = Nokogiri::HTML(open('books/' + filename))
    [file.css('h3.author').text.strip, file.css('h1.title').text.strip]
end

Dir.mkdir('books') unless Dir.exists?('books')

# Fetch all the books and make a simple db entries
# Scraper.start(Book)

# Parse information out of books
# Book.all.map do |b|
#     author, title = parse_author_and_title(b.url)
#     author = Author.find_or_create(:name => author)

#     b.author_id = author.id
#     b.title = title

#     b.save_changes()
# end

File.write('books.json', Book.all.to_json)
File.write('authors.json', Author.all.to_json)