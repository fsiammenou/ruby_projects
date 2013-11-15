
Sequel.migration do
 
  up do
   drop_table(:post_tags)
   create_table(:posts_tags) do
	primary_key :id
	Integer :post_id, :allow_null=>false
	Integer :tag_id, :allow_null=>false
   end
 end

 down do 
   drop_table(:posts_tags)
   create_table(:post_tags) do
	primary_key :id
	Integer :post_id, :allow_null=>false
	Integer :tag_id, :allow_null=>false
   end
 end

end 

