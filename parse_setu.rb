require 'nokogiri'

dir = "setu_pages"

path = File.join(File.dirname(__FILE__), dir, "*")
files = Dir.glob(path)

files.each do |fn|
  File.open(fn, "r") do |file|
    #puts fn
    doc = Nokogiri::HTML(file)
    data = Hash.new
    doc.search("caption h1").each do |node|
      s = node.content
      s = s.split("-").map(&:strip)
      s.pop
      #p s
      code = s.pop
      name = s.join(" - ")
      data["code"] = code
      data["name"] = name
    end

    # Broke pages
    next if data["code"].nil?

    doc.search("h2").each do |node|
      data["faculty"] = node.content
    end

    administered = doc.at('//td[contains(text(), "Administered")]').text.strip
    data["semester"] = administered.match(/Semester (\d)/).captures.first
    data["year"] = administered.match(/Semester \d, (\d+)/).captures.first
    p data["year"]
  end
end



