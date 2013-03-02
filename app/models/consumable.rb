class Consumable < ActiveRecord::Base
	# http://railscasts.com/episodes/47-two-many-to-many
	# http://railscasts.com/episodes/163-self-referential-association

	has_many :synonyms
	has_and_belongs_to_many :categories
	has_many :interactions
	has_many :interactants, :through => :interactions
	has_many :inverse_interactions, :class_name => "Interaction", 
		:foreign_key => "interactant_id"
	has_many :inverse_interactants, :through => :inverse_interactions,
		:source => :consumable

	def all_interactions
		interactions + inverse_interactions
	end

	def all_interactants
		interactants + inverse_interactants
	end

end