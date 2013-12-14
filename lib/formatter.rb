require 'json'
require 'nokogiri'

class Formatter

    @data

    def initialize(data)
        @data = data
    end

    def run
        Dir.chdir('books')
        get_names()
        Dir.chdir('..')
        save_to_json(@data)
    end

    def get_names
        @data.map do |book|
            if book['files']['html']
                file = Nokogiri::HTML(open(book['name'] + '.html'))
                book['author'] = file.css('h3.author').text.strip
                book['title'] = file.css('h1.title').text.strip
            end
        end
    end

    def save_to_json hash
        File.delete('output.json') if File.exists?('output.json')
        File.write('output.json', JSON.generate(hash))
    end

end