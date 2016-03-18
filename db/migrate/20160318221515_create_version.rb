class CreateVersion < ActiveRecord::Migration
  def change
    create_table :versions do |t|
      t.string :number
    end
  end
end
