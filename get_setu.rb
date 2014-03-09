require 'anemone'

index_url = "http://emuapps.monash.edu.au/unitevaluations/wr/uewr_rp1_public_yearseme.jsp"
urls = ["uewr_rp1_public_yearseme.jsp", "uewr_rp1_public_faculties.jsp", "uewr_rp1_public_units.jsp", "uewr_rp1_public.jsp"]

Anemone.crawl(index_url) do |anemone|
  anemone.focus_crawl do |page|
    page.links.select {|foo| urls.any? { |url| foo.to_s.include? url } }
  end
  anemone.on_every_page do |page|
    puts page.url
  end
end
