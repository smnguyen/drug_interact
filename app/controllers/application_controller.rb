class ApplicationController < ActionController::Base
	protect_from_forgery

	def all_names
		names = []
		Consumable.all.each do |consumable|
			names << consumable.name
		end
		Synonym.all.each do |synonym|
			names << synonym.synonym
		end
		Brand.all.each do |brand|
			names << brand.name
		end
		return names
	end
end
