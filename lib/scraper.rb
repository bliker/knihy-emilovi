require 'nokogiri'
require 'open-uri'
require 'net/http'
require 'pp'
require 'json'

class Scraper

    @cookies

    def initialize
        @cookies = get_cookie()
    end

    def run
        prepare_dirs()

        files = []
        links = download_list()
        links.each do |link|
            files << save_book(link)
        end

        save_to_json(files)
        Dir.chdir('..')
    end

    def save_to_json hash
        File.delete('output.json') if File.exists?('output.json')
        File.write('output.json', JSON.generate(hash))
    end

    def save_book link

        def one_format format, link
            print " " + format + ': '
            full_filename = link.split('/')[-1]+'.'+format
            unless File.exists?(full_filename)
                book = fetch_book(format, 'http://zlatyfond.sme.sk'+link)
                if book
                    File.write(full_filename, book)
                    print 'yep'
                    return true
                else
                    print 'nope'
                    return false
                end
            end

            print 'exists'

            return true
        end
        filename = link.split('/')[-1]
        print "Downloading: " + filename
        data = {
            :name => link.split('/')[-1],
            :url => link,
            :files => {
                :html => one_format('html', link),
                :epub => one_format('epub', link),
            }
        }

        print "\n"

        return data
    end

    def fetch_book format, referer, try = 0
        uri = URI('http://zlatyfond.sme.sk/download/' + format)
        req = Net::HTTP::Get.new(uri)

        req['Cookie'] = @cookies
        change_referer(referer)

        res = Net::HTTP.start(uri.hostname, uri.port) { |http| http.request(req) }
        if res.is_a? Net::HTTPSuccess
            return res.body()
        else
            try += 1
            if try > 4
                return false
            else
                print 'Failied: ' + try.to_s
                fetch_book(format, referer, try)
            end
        end
    end

    def change_referer referer
        uri = URI(referer)
        req = Net::HTTP::Get.new(uri)
        req['Cookie'] = @cookies

        res = Net::HTTP.start(uri.hostname, uri.port) { |http| http.request(req) }
        if res.code != '301'
            raise 'Cannot change referer to: ' + referer
        end
    end

    def download_list
        links = []
        page = Nokogiri::HTML(open('http://zlatyfond.sme.sk/diela'))
        page.css('#tu-budu-spisovatelia a[href^="/dielo"]').each do |link|
            links << link.attribute('href').value
        end
        return links
    end

    def get_cookie
        res = Net::HTTP.get_response(URI('http://zlatyfond.sme.sk'))
        if res.code != '200'
            raise 'Cannot retrieve session, check your internets'
        end
        return res['Set-Cookie']
    end

    def prepare_dirs
        Dir.mkdir('books') unless Dir.exists?('books')
        Dir.chdir('books')
    end
end