class CreateConsumables < ActiveRecord::Migration
	def up
		create_table :consumables do |t|
			t.column :drugbank_id,		:string
			t.column :name, 			:string
			t.column :description,		:string
			t.column :indication_text, 	:string
			t.column :mechanism,		:string
			t.column :reference,		:string
			t.column :type,				:string
		end
	end

	def down
		drop_table :consumables
	end
end
