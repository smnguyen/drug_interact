class CreateInteractions < ActiveRecord::Migration
	def up
		create_table :interactions do |t|
			t.column :consumable_id,		:integer
			t.column :interactant_id, 		:integer
			t.column :description,			:string
		end
	end

	def down
		drop_table :interactions
	end
end
