class ConsumablesController < ApplicationController

	# used for front page auto-complete
	def search
	 	@names = []
	 	@names += Consumable.where("name LIKE ?", "#{params[:term]}%").pluck(:name)
	 	@names += Synonym.where("synonym LIKE ?", "#{params[:term]}%").pluck(:synonym)
	 	@names += Brand.where("name LIKE ?", "#{params[:term]}%").pluck(:name)
	 	@names.sort!
	 	render :json => @names
	end

	def groupings
		consumable = Consumable.find_by_name(params[:term])
		@groups = []
		@groups += consumable.categories.pluck(:name)
		if consumable.type == "ActiveIngredient"
			@groups += consumable.indications.pluck(:name)
		end
		@groups.sort!
		
		render :partial => "groupings", :layout => false
	end
end