require 'oba-client'

class CreateIndications < ActiveRecord::Migration
	def load_indications

	end

	def up
		create_table :indications do |t|
			t.column :indication, 	:string
		end
		create_table :active_ingredients_indications, :id => false do |t|
			t.column :active_ingredient_id,		:integer
			t.column :indication_id,			:integer
		end

		load_indications
	end

	def down
		drop_table :indications
		drop_table :active_ingredients_indications
	end
end
