class InteractionsController < ApplicationController

	def find
		@consumables = []
		@interactions = []
		@isPhysician = (params[:isPhysician]=='1')
		# TODO: redirect if no query string
		if params[:ids].nil? then return end 
		
		consumable_ids = []
		params[:ids].each do |id_str|
			consumable = Consumable.find_by_name(id_str)
			if consumable.nil?
				synonym = Synonym.find_by_synonym(id_str)
				consumable = synonym.consumable if !synonym.nil?
			end
			if consumable.nil?
				brand = Brand.find_by_name(id_str)
				next if brand.nil?

				brand.active_ingredients.each do |active_ingredient|
					@consumables << active_ingredient
					consumable_ids << active_ingredient.id
				end
				next
			end

			@consumables << consumable
			consumable_ids << consumable.id
		end

		@interactions = Interaction.where(
			:consumable_id => consumable_ids,
			:interactant_id => consumable_ids
		)
		@food_interactions = Interaction.where(
			:consumable_id => consumable_ids,
			:interactant_id => Food.pluck(:id)
		)
		
		@conflicts = []
		@interactions.each do |interaction|
			@conflicts << interaction.consumable.name
			@conflicts << interaction.interactant.name
		end
		@conflicts.uniq!
		@conflicts.sort!
	end

	def alternatives
		drugToReplace = params[:drugToReplace]
		indicationName = params[:indication]
		@isPhysician = (params[:isPhysician] == '1')
		
		indication = Indication.find_by_name(indicationName)
		allAlternatives = indication.active_ingredients
		
		allAlternativeIDs = []
		allAlternatives.each do |alt|
			allAlternativeIDs << alt.id
		end
		
		consumable_ids = []
		params[:ids].each do |id_str|
			consumable = Consumable.find_by_name(id_str)
			if consumable.nil?
				synonym = Synonym.find_by_synonym(id_str)
				consumable = synonym.consumable if !synonym.nil?
			end
			if consumable.nil?
				brand = Brand.find_by_name(id_str)
				next if brand.nil?

				brand.active_ingredients.each do |active_ingredient|
					consumable_ids << active_ingredient.id
				end
				next
			end

			consumable_ids << consumable.id
		end
		
		interactions = Interaction.where(
			:consumable_id => consumable_ids,
			:interactant_id => allAlternativeIDs
		)
		
		badDrugs = []
		
		interactions.each do |int|
			badDrugs << int.interactant
		end	
		
		@alternatives = allAlternatives - badDrugs
	end

	def resolve
		@consumables = []
		@interactions = []
		# TODO: redirect if no query string
		if params[:ids].nil? then return end 
	
		interaction_ids = []
		consumable_freq = {}
		params[:ids].each do |id|
			begin
				interaction = Interaction.find(id)
			rescue ActiveRecord::RecordNotFound
				next
			end

			@interactions << interaction
			interaction_ids << interaction.id
			
			if consumable_freq[interaction.consumable].nil?
				consumable_freq[interaction.consumable] = 1
			else 
				consumable_freq[interaction.consumable] += 1
			end
			
			if consumable_freq[interaction.interactant].nil?
				consumable_freq[interaction.interactant] = 1
			else
				consumable_freq[interaction.interactant] += 1
			end
		end
		@consumables = consumable_freq.keys.sort {
			|a, b| consumable_freq[b] <=> consumable_freq[a]
		}
	end
end
