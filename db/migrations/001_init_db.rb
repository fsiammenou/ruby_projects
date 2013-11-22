Sequel.migration do
 
  up do
   create_table :users do
      primary_key :id, :type => :Integer
      String :username, :unique=>true
      String :first_name
      String :last_name
      String :password
      String :email
      String :description
      Integer :level
      DateTime :date_registered
      TrueClass :status
   end

   create_table :posts do
      primary_key :id, :type => :Integer
      String :title
      String :content
      DateTime :date_created
      DateTime :date_modified
      TrueClass :status
      String :type
      String :comment_count
      String :filename
      foreign_key :user_id, :users, :type => :Integer
   end

   create_table :comments do
      primary_key :id, :type => :Integer
      String :author
      String :author_email
      String :author_ip
      String :content
      TrueClass :status, :default => false
      DateTime :date
      foreign_key :post_id, :posts, :type => :Integer
   end

   create_table :tags do
      primary_key :id, :type => :Integer
      String :tag
   end

   create_table :posts_tags do
      primary_key :id, :type => :Integer
      foreign_key :tag_id, :tags, :type => :Integer
      foreign_key :post_id, :posts, :type => :Integer
   end
 end

 down do 
   drop_table(:users)
   drop_table(:posts) 
   drop_table(:comments) 
   drop_table(:tags) 
   drop_table(:posts_tags) 
 end

end
