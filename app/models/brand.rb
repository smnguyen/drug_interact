class Brand < ActiveRecord::Base
	has_and_belongs_to_many :active_ingredients
	
	def self.find_by_partial_name(partial_name)
		return Brand.find(
			:all,
			:conditions => ["name LIKE ?", "#{partial_name}%"]
		)
	end
end
