class AddWhenMatchingPatternToChecklists < ActiveRecord::Migration[4.2]
  def change
    add_column :checklists, :with_file_matching_pattern, :string
  end
end
