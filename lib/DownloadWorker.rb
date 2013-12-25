class DownloadWorker

    def initialize
        # Each worker has individual cookie
        @cookie = get_cookie()
    end

    def start links, model
        link = links.pop
        while link
            book = get_book(link)
            if book[:html]
                model.insert(book)
            end
            link = links.pop
        end
    end

    def get_book link

        filename = link.split('/')[-1]
        puts "Downloading: " + filename

        data = {
            :url => link,
            :html => get_one_format('html', link),
            :epub => get_one_format('epub', link),
        }

        return data
    end

    def get_one_format format, link
        full_filename = link.split('/')[-1] + '.' + format
        unless File.exists?('books/' + full_filename)
            book = fetch(format, 'http://zlatyfond.sme.sk' + link)
            if book
                File.write('books/' + full_filename, book)
                return true
            else
                return false
            end
        end
        return true
    end

    protected

    def fetch format, referer, try = 0
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
            if try > 2
                return false
            else
                print ' Fail ' + try.to_s
                fetch(format, referer, try)
            end
        end
    end

    # Remote manipulation methods

    def get_cookie
        res = Net::HTTP.get_response(URI('http://zlatyfond.sme.sk'))
        if res.code != '200'
            raise 'Cannot retrieve session, check your internets'
        end
        return res['Set-Cookie']
    end

    def change_referer referer
        uri = URI(referer)
        req = Net::HTTP::Get.new(uri)
        req['Cookie'] = @cookie

        res = Net::HTTP.start(uri.hostname, uri.port) { |http| http.request(req) }
        unless ['200', '301'].include? res.code
            raise 'Cannot change referer to: ' + referer
        end
    end
end