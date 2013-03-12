class InteractionsController < ApplicationController

	def find
		@consumables = []
		@interactions = []
		@isPhysician = (params[:isPhysician]=='1')
		# TODO: redirect if no query string
		if params[:ids].nil? then return end 
		
		consumable_ids = []
		params[:ids].each do |id_str|
			consumable = Consumable.where("name LIKE ?", id_str).first
			if consumable.nil?
				synonym = Synonym.where("synonym LIKE ?", id_str).first
				consumable = synonym.consumable if !synonym.nil?
			end
			if consumable.nil?
				brand = Brand.where("name LIKE ?", id_str).first
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
		
		# TODO: refactor with get_conflicts
		@conflicts = []
		@interactions.each do |interaction|
			@conflicts << interaction.consumable.name
			@conflicts << interaction.interactant.name
		end
		@conflicts.uniq!
		@conflicts.sort!
	end

	def alternatives
		@drugToReplace = params[:drugToReplace]
		@indicationName = params[:indication]
		@isPhysician = (params[:isPhysician] == '1')
		params[:ids].delete(@drugToReplace)

		indication = Indication.find_by_name(@indicationName)
		allAlternatives = indication.active_ingredients
		allAlternativeIDs = allAlternatives.pluck(:id)
		
		consumable_ids = []
		@consumables = []
		params[:ids].each do |id_str|
			consumable = Consumable.find_by_name(id_str)
			if consumable.nil?
				synonym = Synonym.find_by_synonym(id_str)
				consumable = synonym.consumable if !synonym.nil?
			end
			if consumable.nil?
				brand = Brand.find_by_name(id_str)
				next if brand.nil?
				consumable_ids += brand.active_ingredients.pluck(:id)
				@consumables += brand.active_ingredients.pluck(:name)
				next
			end

			consumable_ids << consumable.id
			@consumables << consumable.name
		end
		
		interactions = Interaction.where(
			:consumable_id => consumable_ids,
			:interactant_id => allAlternativeIDs
		)
		inverse_interactions = Interaction.where(
			:consumable_id => allAlternativeIDs,
			:interactant_id => consumable_ids
		)

		badDrugs = []
		interactions.each do |int|
			badDrugs << int.interactant
		end
		inverse_interactions.each do |int|
			badDrugs << int.consumable
		end

		@alternatives = allAlternatives - badDrugs
		@consumables.uniq!
	end

	def resolve
		# TODO: redirect if no query string
		if params[:iid].nil? then return end 
		if params[:cid].nil? then return end
		
		@consumables = Consumable.where(:id => params[:cid])
		@interactions = Interaction.where(:id => params[:iid])
		@conflicts = get_conflicts(@interactions)
	end

	private

	# returns list of conflicts from list of interactions
	# drugs are sorted by the number of interactions they appear in
	def get_conflicts(interactions)
		conflict_freq = {}
		interactions.each do |int|			
			if conflict_freq[int.consumable].nil?
				conflict_freq[int.consumable] = 1
			else 
				conflict_freq[int.consumable] += 1
			end
			
			if conflict_freq[int.interactant].nil?
				conflict_freq[int.interactant] = 1
			else
				conflict_freq[int.interactant] += 1
			end
		end
		conflicts = conflict_freq.keys.sort {
			|a, b| conflict_freq[b] <=> conflict_freq[a]
		}
		return conflicts
	end
end
