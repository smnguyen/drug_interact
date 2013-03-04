class Brand < ActiveRecord::Base
	has_and_belongs_to_many :active_ingredients
	
end
