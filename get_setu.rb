require 'anemone'
require 'cgi'

index_url = "http://emuapps.monash.edu.au/unitevaluations/wr/uewr_rp1_public_yearseme.jsp"
#index_url = "http://emuapps.monash.edu.au/unitevaluations/wr/uewr_rp1_public_units.jsp?semester=2&year=2011&faculty_cd=50000565"
urls = ["uewr_rp1_public_yearseme.jsp", "uewr_rp1_public_faculties.jsp", "uewr_rp1_public_units.jsp", "uewr_rp1_public.jsp"]
dir = "setu_pages"

Anemone.crawl(index_url) do |anemone|
  anemone.focus_crawl do |page|
    page.links.select {|foo| urls.any? { |url| foo.to_s.include? url } }
  end

  anemone.on_every_page do |page|
    puts "Looking at #{page.url}"
  end

  anemone.on_pages_like(Regexp.new urls[-1]) do |page|
    #puts "BINGO #{page.url}"
    #puts page.body
    query = CGI.parse(page.url.query)
    filename = "#{query["unit_cd"][0]}_#{query["semester"][0]}_#{query["year"][0]}.html"
    filepath = File.join(File.dirname(__FILE__), dir, filename)

    File.open(filepath, "w") { |file| file.write(page.body) }
    puts filename
  end

end
