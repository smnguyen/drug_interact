require 'nokogiri'

drugbank = File.open("small.xml")
xml = Nokogiri::XML(drugbank) do |config|
	config.options = 
  		Nokogiri::XML::ParseOptions::RECOVER | 
  		Nokogiri::XML::ParseOptions::NOBLANKS |
  		Nokogiri::XML::ParseOptions::HUGE
end
drugbank.close

xml.css('drugs > drug').each do |node|
	drug = Nokogiri::XML(node.to_s)
	puts drug.xpath('drug/drugbank-id').text.strip
	puts drug.xpath('drug/name').text.strip
	drug.xpath('drug/drug-interactions/drug-interaction').each do |int|
		puts (int > 'drug').text
		puts (int > 'description').text
	end
	puts "\n"
end