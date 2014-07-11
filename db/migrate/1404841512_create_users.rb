class CreateUsers < ActiveRecord::Migration
  def up
    create_table :users do |t|
      t.string :username
      t.string :password
    end
    create_table :fish do |t|
      t.string :fishname
    end
  end
  def down
    drop_table :users
    drop_table :fish
  end
end
