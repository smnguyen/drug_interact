class CreateCategorizations < ActiveRecord::Migration
	# create join table for categories & consumables
	def up
		create_table :categories_consumables, :id => false do |t|
			t.column :consumable_id,	:integer
			t.column :category_id,		:integer
		end
	end

	def down
		drop_table :categorizations
	end
end
