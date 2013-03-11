require 'oba-client'
require 'nokogiri'

class CreateIndications < ActiveRecord::Migration
	def get_terms (result)
		terms = []
		result[:annotations].each do |annotation|
			term = annotation[:concept][:preferredName]
			annotation[:concept][:semanticTypes].each do |semantic_type|
				description = semantic_type[:description]
				if description == "Disease or Syndrome" ||
				   description == "Neoplastic Process" ||
				   description == "Injury or Poisoning" ||
				   description == "Therapeutic or Preventive Procedure" ||
				   description == "Mental or Behavioral Dysfunction" ||
				   description == "Sign or Symptom" ||
				   description == "Pathological Function" ||
				   description == "Finding" ||
				   description == "Diagnostic Procedure" ||
				   description == "Pharmacologic Substance"

			    	terms << term
			    	break
				end
			end
		end
		terms.uniq!
		return terms
	end

	def load_indications
		drugbank = File.open('drugbank.xml')
		xml = Nokogiri::XML(drugbank) do |config|
		config.options = 
	  		Nokogiri::XML::ParseOptions::RECOVER | 
	  		Nokogiri::XML::ParseOptions::NOBLANKS |
	  		Nokogiri::XML::ParseOptions::HUGE
		end
		drugbank.close

		oba_client = OBAClient.new(
			:longestOnly => 'false',
			:wholeWordOnly => 'true',
			:filterNumber => 'true',
			:withDefaultStopWords => 'true',
			:isStopWordsCaseSensitive => 'false',
			:minTermSize => '4',
			:scored => 'true',
			:withSynonyms => 'true',
			:ontologiesToExpand => '46896',
			:ontologiesToKeepInResult => '46896',
			:isVirtualOntologyID => 'false',
			:semanticTypes => '',
			:levelMax => '0',
			:mappingTypes => '',
			:format => 'xml',
			:apikey => '75b9dd20-9017-41dc-9e4c-40748d04d6bf'
		)

		xml.css('drugs > drug').each do |node|
			drug = Nokogiri::XML(node.to_s)
			drugbank_id = drug.xpath('drug/drugbank-id').text
			ingredient = ActiveIngredient.find_by_drugbank_id(drugbank_id)
			indication_text = drug.xpath('drug/indication').text

			result_xml = oba_client.execute(indication_text)
			result = OBAClient::parse(result_xml)
			terms = get_terms(result)
			terms.each do |term|
				indication = Indication.find_by_name(term)
				if indication.nil?
					indication = Indication.new(:name => term)
				end
				ingredient.indications << indication
			end
			ingredient.save(:validate => false)
		end
	end

	def up
		create_table :indications do |t|
			t.column :name, 	:string
		end
		create_table :active_ingredients_indications, :id => false do |t|
			t.column :active_ingredient_id,		:integer
			t.column :indication_id,			:integer
		end

		load_indications
	end

	def down
		drop_table :indications
		drop_table :active_ingredients_indications
	end
end
