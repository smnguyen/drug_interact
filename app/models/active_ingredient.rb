class ActiveIngredient < Consumable
	has_and_belongs_to_many :brands
	has_and_belongs_to_many :indications
	has_many :similarity_scores
	has_many :similar_ingredients, :through => :similarity_scores
	has_many :inverse_similarity_scores, :class_name => "SimilarityScore",
		:foreign_key => "similar_ingredient_id"
	has_many :inverse_similar_ingredients, :through => :inverse_similarity_scores,
		:source => :active_ingredient

	def drugbank_url
		return "http://www.drugbank.ca/drugs/#{drugbank_id}"
	end

	def micromedex_url
		return "http://www.micromedexsolutions.com.laneproxy.stanford.edu/
				micromedex2/librarian/ND_T/evidencexpert/ND_PR/evidencexpert/
				CS/E7D7AE/ND_AppProduct/evidencexpert/DUPLICATIONSHIELDSYNC/
				F94375/ND_PG/evidencexpert/ND_B/evidencexpert/ND_P/evidencexpert/
				PFActionId/evidencexpert.DoIntegratedSearch?SearchTerm=#{name}"
	end

	def drugs_com_url
		return "http://www.drugs.com/search.php?searchterm=#{name}"
	end
end
