class SimilarityScore < ActiveRecord::Base
	belongs_to :active_ingredient
	belongs_to :similar_ingredient, :class_name => "ActiveIngredient"
	
end
