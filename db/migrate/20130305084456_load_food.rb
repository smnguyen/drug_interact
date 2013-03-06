class LoadFood < ActiveRecord::Migration
	def up
		
	end
	
	def down
		Food.delete_all
	end
end
