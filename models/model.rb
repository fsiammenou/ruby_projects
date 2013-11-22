<<<<<<< HEAD
class User < Sequel::Model
  one_to_many :posts
end

class Post < Sequel::Model
  many_to_one :user
  one_to_many :comments
  one_to_many :posts_tags
end

class Comment < Sequel::Model
  many_to_one :post
end

class Tag < Sequel::Model
  one_to_many :posts_tags
  one_to_many :posts
end
=======

class User < Sequel::Model
  one_to_many :posts
end 

class Post < Sequel::Model
  one_to_many :comments
  many_to_one :user 
  many_to_many :tags
end 

class Comment < Sequel::Model
  many_to_one :post
end 

class Tag < Sequel::Model
  many_to_many :posts
end 

>>>>>>> 3ead1851c3a48598d54848047b7753a857256ea8
