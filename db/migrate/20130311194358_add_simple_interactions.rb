class AddSimpleInteractions < ActiveRecord::Migration
	def up
		add_column :interactions, :simple_description, :string
		Interaction.reset_column_information

		Interaction.find_each do |interaction|
			interaction.update_attribute(
				:simple_description, interaction.description
			)
			interaction.save(:validate => false)
		end

		puts "Adding simple descriptions from file"
		f = File.open('interactions_annotated.txt')
		while line = f.gets
			line.chomp!
			info = line.split(/\t/)
			if info.length == 3
				break
			end
			puts info[3]
			consumable = Consumable.find_by_name(info[0])
			interactant = Consumable.find_by_name(info[1])
			interactions = Interaction.where(
				:consumable_id => consumable.id,
				:interactant_id => interactant.id
			)
			if interactions.length != 1
				puts "ERROR!"
				break
			end
			interactions[0].update_attribute(:simple_description, info[3])
			interactions[0].save(:validate => false)
		end
		f.close()
	end

	def down
		remove_column :interactions, :simple_description
	end
end
