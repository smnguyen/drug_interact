class ActiveIngredient < Consumable
	has_and_belongs_to_many :brands
	has_and_belongs_to_many :indications

end
