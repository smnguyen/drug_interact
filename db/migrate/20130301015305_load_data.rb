require 'nokogiri'

class LoadData < ActiveRecord::Migration
	def up
  		drugbank = File.open("drugbank.xml")
		xml = Nokogiri::XML(drugbank) do |config|
			config.options = 
  				Nokogiri::XML::ParseOptions::RECOVER | 
  				Nokogiri::XML::ParseOptions::NOBLANKS |
  				Nokogiri::XML::ParseOptions::HUGE
		end
		drugbank.close

		# load consumables
		xml.css('drugs > drug').each do |drug_node|
			data = Nokogiri::XML(drug_node.to_s)
			
			# OPTIMIZE: skip drug if certain fields are empty??
			# TODO: strip  HTML from fields
			# add consumable
			id = data.xpath('drug/drugbank-id').text
			name = data.xpath('drug/name').text
			description = data.xpath('drug/description').text
			indication = data.xpath('drug/indication').text
			consumable = Consumable.new(
				:drugbank_id => id,
				:name => name,
				:description => description,
				:indication_text => indication
			)

			# add synonyms
			data.xpath('drug/synonyms/synonym').each do |synonym_node|
				synonym = Synonym.new(
					:consumable_id => consumable.id,
					:synonym => synonym_node.text
				)
				consumable.synonyms << synonym
			end

			# add categories
			data.xpath('drug/categories/category').each do |category_node|
				category = Category.find_by_name(category_node.text)
				if category.nil?
					category = Category.new(:name => category_node.text)
				end
				consumable.categories << category
			end

			consumable.save(:validate => false)
		end

		# load interactions
		xml.css('drugs > drug').each do |drug_node|
			data = Nokogiri::XML(drug_node.to_s)
			drugbank_id = data.xpath('drug/drugbank-id').text
			consumable = Consumable.find_by_drugbank_id(drugbank_id)

			data.xpath('drug/drug-interactions/drug-interaction').each do |i_node|
				interactant_dbid = (i_node > 'drug').text
				description = (i_node > 'description').text
				interactant = Consumable.find_by_drugbank_id(interactant_dbid)
				if interactant.nil? then next end
				
				# OPTIMIZE: don't need interaction_forward??
				interaction_forward = Interaction.find(
					:first,
					:conditions => {
						:consumable_id => consumable.id,
						:interactant_id => interactant.id
					}					
				)
				interaction_reverse = Interaction.find(
					:first,
					:conditions => {
						:consumable_id => interactant.id,
						:interactant_id => consumable.id
					}					
				)
				if !(interaction_forward.nil? && interaction_reverse.nil?)
					next 
				end
				
				interaction = Interaction.new(
					:consumable_id => consumable.id,
					:interactant_id => interactant.id,
					:description => description
				)
				interaction.save(:validate => false)
			end
		end
	end

	def down
		Consumable.delete_all
		Synonym.delete_all
		Category.delete_all
		Interaction.delete_all
	end
end
