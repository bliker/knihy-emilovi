class Scraper

    def initialize
    end

    def self.start model
        links = download_list()
        workers = (1..5).map do |w|
            Thread.new(w) do |th|
                d = DownloadWorker.new
                d.start links, model
            end
        end
        workers.each { |w| w.join }
    end

    protected

    def self.download_list
        links = []
        page = Nokogiri::HTML(open('http://zlatyfond.sme.sk/diela'))
        page.css('#tu-budu-spisovatelia a[href^="/dielo"]').each do |link|
            links << link.attribute('href').value
        end
        return links
    end
end