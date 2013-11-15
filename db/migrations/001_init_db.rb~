
Sequel.migration do
 
  up do
   create_table(:users) do
	primary_key :id
	String :username, :size=>30, :unique=>true
	String :password, :size=>30
	String :realname, :size=>60
   end

   create_table(:posts) do
	primary_key :id
	Integer :user_id, :allow_null=>false 
	String :title, :size=>500
	Text :content
	Datetime :date_created
	Datetime :date_updated
   end

   create_table(:comments) do
	primary_key :id
	Integer :post_id
	String :author, :size=>60
	Text :comment
	Datetime :date_added 
   end

   create_table(:tags) do
	primary_key :id
	String :tag, :size=>100
   end

   create_table(:post_tags) do
	primary_key :id
	Integer :post_id, :allow_null=>false
	Integer :tag_id, :allow_null=>false
   end
 end

 down do 
   drop_table(:users)
   drop_table(:posts) 
   drop_table(:comments) 
   drop_table(:tags) 
   drop_table(:post_tags) 
 end

end 

