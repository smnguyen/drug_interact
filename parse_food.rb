require 'nokogiri'

drugbank = File.open('drugbank.xml')
xml = Nokogiri::XML(drugbank) do |config|
	config.options = 
  		Nokogiri::XML::ParseOptions::RECOVER | 
  		Nokogiri::XML::ParseOptions::NOBLANKS |
  		Nokogiri::XML::ParseOptions::HUGE
end
drugbank.close

xml.css('drugs > drug').each do |node|
	drug = Nokogiri::XML(node.to_s)
	db_id = drug.xpath('drug/drugbank-id').text
	name = drug.xpath('drug/name').text
	drug.xpath('drug/food-interactions/food-interaction').each do |food_node|
		puts "#{db_id}\t#{name}\t#{food_node.text}" 
	end
end