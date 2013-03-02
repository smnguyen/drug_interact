class CreateSynonyms < ActiveRecord::Migration
	def up
		create_table :synonyms do |t|
			t.column :consumable_id, 	:integer
			t.column :synonym,			:string
		end
	end

	def down
		drop_table :synonyms
	end
end
