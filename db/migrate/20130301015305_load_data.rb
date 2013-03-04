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
			# TODO: strip HTML from fields
			# add consumable
			id = data.xpath('drug/drugbank-id').text
			name = data.xpath('drug/name').text
			description = data.xpath('drug/description').text
			indication = data.xpath('drug/indication').text
			mechanism = data.xpath('drug/mechanism-of-action').text
			reference = data.xpath('drug/general-references').text
			ingredient = ActiveIngredient.new(
				:drugbank_id => id,
				:name => name,
				:description => description,
				:indication_text => indication,
				:mechanism => mechanism,
				:reference => reference
			)

			# add synonyms
			data.xpath('drug/synonyms/synonym').each do |synonym_node|
				synonym = Synonym.new(
					:consumable_id => ingredient.id,
					:synonym => synonym_node.text
				)
				ingredient.synonyms << synonym
			end

			# add categories
			data.xpath('drug/categories/category').each do |category_node|
				category = Category.find_by_name(category_node.text)
				if category.nil?
					category = Category.new(:name => category_node.text)
				end
				ingredient.categories << category
			end

			ingredient.save(:validate => false)
		end

		# load interactions
		xml.css('drugs > drug').each do |drug_node|
			data = Nokogiri::XML(drug_node.to_s)
			drugbank_id = data.xpath('drug/drugbank-id').text
			ingredient = ActiveIngredient.find_by_drugbank_id(drugbank_id)

			data.xpath('drug/drug-interactions/drug-interaction').each do |i_node|
				interactant_dbid = (i_node > 'drug').text
				description = (i_node > 'description').text
				interactant = ActiveIngredient.find_by_drugbank_id(interactant_dbid)
				if interactant.nil? then next end
				
				small_id = [ingredient.id, interactant.id].min
				large_id = [ingredient.id, interactant.id].max
				interaction = Interaction.find(
					:first,
					:conditions => {
						:consumable_id => small_id,
						:interactant_id => large_id
					}					
				)
				if !interaction.nil?
					next 
				end
				
				interaction = Interaction.new(
					:consumable_id => small_id,
					:interactant_id => large_id,
					:description => description
				)
				interaction.save(:validate => false)
			end
		end
	end

	def down
		ActiveIngredient.delete_all
		Synonym.delete_all
		Category.delete_all
		Interaction.delete_all
	end
end
