require 'nokogiri'
require 'open-uri'
require 'net/http'
require 'pp'
require 'json'

class Scraper

    def initialize

    end

    def run
        prepare_dirs()

        files = []
        links = download_list()
        workers = (1..5).map do |w|
            Thread.new(w) do |th|
                d = DownloadWorker.new
                d.start links, files
            end
        end

        workers.each { |w| w.join }
        Dir.chdir('..')

        save_to_json(files)
    end

    protected

    def save_to_json hash
        File.delete('output.json') if File.exists?('output.json')
        File.write('output.json', JSON.generate(hash))
    end

    def download_list
        links = []
        page = Nokogiri::HTML(open('http://zlatyfond.sme.sk/diela'))
        page.css('#tu-budu-spisovatelia a[href^="/dielo"]').each do |link|
            links << link.attribute('href').value
        end
        return links
    end

    def prepare_dirs
        Dir.mkdir('books') unless Dir.exists?('books')
        Dir.chdir('books')
    end
end

class DownloadWorker

    def initialize
        @cookie = get_cookie()
    end

    def get_cookie
        res = Net::HTTP.get_response(URI('http://zlatyfond.sme.sk'))
        if res.code != '200'
            raise 'Cannot retrieve session, check your internets'
        end
        return res['Set-Cookie']
    end

    def start input, output
        link = input.pop
        while link
            output << save_book(link)
            link = input.pop
        end
    end

    def save_book link

        filename = link.split('/')[-1]
        puts "Downloading: " + filename
        data = {
            :name => link.split('/')[-1],
            :url => link,
            :files => {
                :html => one_format('html', link),
                :epub => one_format('epub', link),
            }
        }

        return data
    end

    def one_format format, link
        full_filename = link.split('/')[-1]+'.'+format
        unless File.exists?(full_filename)
            book = fetch_book(format, 'http://zlatyfond.sme.sk'+link)
            if book
                File.write(full_filename, book)
                return true
            else
                return false
            end
        end
        return true
    end

    def fetch_book format, referer, try = 0
        uri = URI('http://zlatyfond.sme.sk/download/' + format)
        req = Net::HTTP::Get.new(uri)

        req['Cookie'] = @cookie
        change_referer(referer)

        res = Net::HTTP.start(uri.hostname, uri.port) { |http| http.request(req) }
        # res = Net::HTTP::Proxy('127.0.0.1', '8888').start(uri.hostname, uri.port) { |http| http.request(req) }
        # pp @cookie
        if res.is_a? Net::HTTPSuccess
            return res.body()
        else
            try += 1
            if try > 4
                return false
            else
                print ' Fail ' + try.to_s
                fetch_book(format, referer, try)
            end
        end
    end

    def change_referer referer
        uri = URI(referer)
        req = Net::HTTP::Get.new(uri)
        req['Cookie'] = @cookie

        res = Net::HTTP.start(uri.hostname, uri.port) { |http| http.request(req) }
        unless  ['200', '301'].include? res.code
            raise 'Cannot change referer to: ' + referer
        end
    end

end