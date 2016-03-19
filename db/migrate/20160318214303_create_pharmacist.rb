class CreatePharmacist < ActiveRecord::Migration
  def change
    create_table :pharmacists do |t|
      t.string :rpps_id, null: false
      t.string :first_name
      t.string :last_name
      t.string :email_address
      t.string :siret
      t.string :siren
      t.string :finess
      t.string :finess_judicial
    end

     add_index "pharmacists", ["rpps_id"], name: "index_pharmacists_on_rpps_id", unique: true, using: :btree
  end
end
