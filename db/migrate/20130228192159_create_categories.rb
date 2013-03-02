class CreateCategories < ActiveRecord::Migration
	def up
		create_table :categories do |t|
			t.column :name, 	:string
		end
	end

	def down
		drop_table :categories
	end
end
