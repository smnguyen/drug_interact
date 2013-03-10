module ApplicationHelper

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
