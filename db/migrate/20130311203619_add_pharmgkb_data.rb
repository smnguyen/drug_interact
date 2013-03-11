class AddPharmgkbData < ActiveRecord::Migration
	def up
		add_column :interactions, :source, :string
		Interaction.reset_column_information

		Interaction.find_each do |interaction|
			interaction.update_attributes(:source => "Drugbank")
		end

		puts "Adding new interactions"
		f = File.open('pharmGKB-druginteractions.csv')
		f.gets # toss header line
		while line = f.gets 
			line.chomp!
			pGKB_id_1, name_1, pGKB_id_2, name_2, *text = line.split(',')
			name_1 = name_1[1..-2]
			name_2 = name_2[1..-2]
			description = text.join(',')

			ingredients_1 = ActiveIngredient.where("name LIKE ?", name_1)
			next if ingredients_1.length != 1
			
			ingredients_2 = ActiveIngredient.where("name LIKE ?", name_2)
			next if ingredients_2.length != 1

			small_id = [ingredients_1[0].id, ingredients_2[0].id].min
			large_id = [ingredients_1[0].id, ingredients_2[0].id].max
			interaction = Interaction.find(
				:first,
				:conditions => {
					:consumable_id => small_id,
					:interactant_id => large_id
				}
			)
			if !interaction.nil?
				next
			end
			interaction = Interaction.new(
				:consumable_id => small_id,
				:interactant_id => large_id,
				:description => description,
				:simple_description => description,
				:source => "PharmGKB"
			)
			interaction.save(:validate => false)
		end
		f.close()
	end

	def down
		Interaction.where(:source => "PharmGKB").delete_all
		remove_column :interactions, :source
	end
end
