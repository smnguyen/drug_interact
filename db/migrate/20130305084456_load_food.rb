class LoadFood < ActiveRecord::Migration
	def up
		f = File.open('food_interactions.txt')
		while line = f.gets
			line.chomp!
			db_id, description, *foods = line.split(/\t/)
			active_ingredient = ActiveIngredient.find_by_drugbank_id(db_id)
			foods.each do |food_name|
				food = Food.find_by_name(food_name)
				if food.nil?
					food = Food.new(:name => food_name)
					food.save(:validate => false)
				end
				interaction = Interaction.new(
					:consumable_id => active_ingredient.id,
					:interactant_id => food.id,
					:description => description
				)
				interaction.save(:validate => false)
			end
		end
		f.close
	end
	
	def down
		Food.delete_all
	end
end
