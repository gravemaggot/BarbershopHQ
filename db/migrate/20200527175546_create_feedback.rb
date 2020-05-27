class CreateFeedback < ActiveRecord::Migration[6.0]
  def change
    create_table :feedbacks do |t|
      t.text :content

      t.timestamps
    end
  end
end
