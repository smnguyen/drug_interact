module ApplicationHelper

	def all_names
		return Consumable.pluck(:name) + Synonym.pluck(:synonym) + Brand.pluck(:name)
	end

end
