class Synonym < ActiveRecord::Base
	belongs_to :consumable

	def self.find_by_partial_synonym(partial_synonym)
		return Synonym.find(
			:all,
			:conditions => ["synonym LIKE ?", "#{partial_synonym}%"]
		)
	end
end
