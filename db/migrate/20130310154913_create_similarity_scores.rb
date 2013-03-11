class CreateSimilarityScores < ActiveRecord::Migration
	def up
		get_matrix
		
		# might be buggy, comment out if needed
		while true
			puts "Run calculate_similarity_scores.py before continuing"
			puts "Continue? (y or n)"
			continue = gets
			break if continue.downcase[0] == 'y'
		end

		create_table :similarity_scores do |t|
			t.column :active_ingredient_id,		:integer
			t.column :similar_ingredient_id,	:integer
			t.column :score,					:float
		end

		load_scores
	end

	def down
		drop_table :similarity_scores
	end

	# run python script on this matrix file to get scores
	def get_matrix
		num_categories = Category.all.length
		f = File.open('matrix.txt', 'w')
		ActiveIngredient.find_each do |ingredient|
			dataset = ingredient.categories.pluck(:id)
			ingredient.indications.pluck(:id).each do |indication_id|
				dataset << (indication_id + num_categories)
			end
			f.puts "#{ingredient.id}\t#{dataset.join(",")}"
		end
		f.close()
	end

	def load_scores
		f = File.open('scores.txt')
		while line = f.gets
			ids, sim_score = line.split(/\t/)
			id1, id2 = ids.split(/,/)
			id1 = id1.to_i
			id2 = id2.to_i

			score = SimilarityScore.new(
				:active_ingredient_id => id1, #[id1, id2].min,
				:similar_ingredient_id => id2, #[id1, id2].max,
				:score => sim_score.to_f
			)
			score.save(:validate => false)

			# OPTIMIZE: makes other computations easier, but 2x memory
			score_2 = SimilarityScore.new(
				:active_ingredient_id => id2,
				:similar_ingredient_id => id1,
				:score => sim_score.to_f
			)
			score_2.save(:validate => false)
		end
		f.close
	end

end
