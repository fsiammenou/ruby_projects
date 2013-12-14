
Sequel.migration do
 
 up do
    from(:users).insert(:username=>'username',:password=>'password',:email=>'admin@admin.com',:status=>1)
 end

 down do 
  
 end

end 
