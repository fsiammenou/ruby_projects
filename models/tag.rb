class Tag < Sequel::Model
  one_to_many :posts_tags
  one_to_many :posts
end
