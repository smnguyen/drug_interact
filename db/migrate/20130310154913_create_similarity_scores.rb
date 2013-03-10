class CreateSimilarityScores < ActiveRecord::Migration
	def up
		create_table :similarity_scores do |t|
			t.column :active_ingredient_id,		:integer
			t.column :similar_ingredient_id,	:integer
			t.column :score,					:float
		end

		load_similarity_scores
	end

	def down
		drop_table :similarity_scores
	end

	def load_similarity_scores
		ActiveIngredient.find_each do |ingredient_a|
			categories_a = ingredient_a.categories
			indications_a = ingredient_a.indications
			total = categories_a.length + indications_a.length

			ActiveIngredient.find_each do |ingredient_b|
				n_sim_categories = (ingredient_b.categories & categories_a).length
				n_sim_indications = (ingredient_b.indications & indications_a).length
				shared_count = n_sim_indications + n_sim_categories
				next if shared_count == 0
				score = SimilarityScore.new(
					:active_ingredient_id => ingredient_a.id,
					:similar_ingredient_id => ingredient_b.id,
					:score => shared_count.to_f / total
				)
				score.save(:validate => false)
			end
		end
	end

end
