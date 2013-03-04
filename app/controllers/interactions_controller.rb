class InteractionsController < ApplicationController

	def find
		@consumables = []
		@interactions = []
		# TODO: redirect if no query string
		if params[:ids].nil? then return end 
		
		consumable_ids = []
		params[:ids].each do |id_str|
			begin
				#finds consumable based on id
				consumable = Consumable.find(id_str.to_i)
			rescue ActiveRecord::RecordNotFound
				next
			end

			@consumables << consumable
			consumable_ids << consumable.id
		end

		@interactions = Interaction.where(
			:consumable_id => consumable_ids,
			:interactant_id => consumable_ids
		)
	end

	def resolve

	end

end
