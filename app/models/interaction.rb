class Interaction < ActiveRecord::Base
	belongs_to :consumable
	belongs_to :interactant, :class_name => "Consumable"

end
