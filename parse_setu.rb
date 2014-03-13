require 'nokogiri'
require 'csv'

dir = "setu_pages"

path = File.join(File.dirname(__FILE__), dir, "*")
files = Dir.glob(path)

# For older SETU questionnaires with 8 questions
old_setu_mappings = {
  2 => 1,
  3 => 2,
  4 => 3,
  5 => 4,
  8 => 5
}

cols = %w[code name faculty year semester enrolled completed question1 question2 question3 question4 question5]

CSV.open("setu.csv", "wb") do |csv|
  # Header
  csv << cols

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
      data["semester"] = administered.match(/Semester (\d)/).captures.first.to_i
      data["year"] = administered.match(/Semester \d, (\d+)/).captures.first.to_i

      enrolled = doc.at('//td[contains(text(), "Enrolled:")]').text.strip
      data["enrolled"] = enrolled.match(/Enrolled: (\d+)/).captures.first.to_i

      completed = doc.at('//td[contains(text(), "questionnaires")]').text.strip
      data["completed"] = completed.match(/completed: (\d+)/).captures.first.to_i

      # We only care about Clayton campus subjects for now
      medians = doc.xpath('//font[contains(text(), "Clayton")]')
      next if medians.nil? or medians.length == 0
      puts fn, medians.length
      medians.each_with_index do |node, index|
        # 1-indexed questions
        index = index + 1
        median = node.parent.parent.parent.css("td")[1].text.strip.to_f
        if medians.length == 8 and old_setu_mappings.include? index
          #puts "mapping #{node.text.strip}: #{median}, #{index} to #{old_setu_mappings[index]}"
          data["question#{old_setu_mappings[index]}"] = median
        elsif medians.length == 5
          data["question#{index}"] = median
          #puts "normal #{node.text.strip}: #{median}, #{index}"
        else
          #puts "unmapped #{index}"
        end
        #puts "#{node.text.strip}: #{median}, #{question}"

      end

      csv_arr = []
      cols.each do |col|
        csv_arr << data[col]
      end
      csv << csv_arr
    end
  end
end



