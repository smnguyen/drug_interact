require 'nokogiri'

class CreateBrands < ActiveRecord::Migration
	def load_brands
		drugbank = File.open("drugbank.xml")
		xml = Nokogiri::XML(drugbank) do |config|
			config.options = 
  				Nokogiri::XML::ParseOptions::RECOVER | 
  				Nokogiri::XML::ParseOptions::NOBLANKS |
  				Nokogiri::XML::ParseOptions::HUGE
		end
		drugbank.close

		xml.css('drugs > drug').each do |drug_node|
			data = Nokogiri::XML(drug_node.to_s)
			drugbank_id = data.xpath('drug/drugbank-id').text
			ingredient = ActiveIngredient.find_by_drugbank_id(drugbank_id)

			# add brands
			data.xpath('drug/brands/brand').each do |brand_node|
				brand_name = brand_node.text
				brand = Brand.find_by_name(brand_name)
				if brand.nil?
					brand = Brand.new(:name => brand_name)
				end
				ingredient.brands << brand
			end

			# add mixtures
			data.xpath('drug/mixtures/mixture').each do |mixture_node|
				brand_name = (mixture_node > 'name').text
				mixture = (mixture_node > 'ingredients').text
				brand = Brand.find_by_name(brand_name)
				if brand.nil?
					brand = Brand.new(
						:name => brand_name,
						:mixture => mixture
					)
				end
				ingredient.brands << brand
			end

			ingredient.save(:validate => false)
		end
	end

	def up
    	create_table :brands do |t|
    		t.column :name, 	:string
    		t.column :mixture,	:string
    	end
    	create_table :active_ingredients_brands, :id => false do |t|
    		t.column :brand_id,					:integer
    		t.column :active_ingredient_id,		:integer
    	end

    	load_brands
  	end

  	def down
  		drop_table :brands
  		drop_table :brand_mixtures
  	end
end
