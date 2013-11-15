
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

