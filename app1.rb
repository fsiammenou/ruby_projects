
class App < Sinatra::Application
  #we may add a setting for the error to be showm or not
  #and may use different configuration for users and programmers (us)
  #on the other hand
  configure do
    set :db, Sequel.sqlite('./db/data.db')
  end

  get '/' do
    #haml:home 
    # contain welcoming and 
    # links for login or to browsePosts (public homepage)		
    "Welcome!"
  end

  get '/browsePosts' do
    #here will be the public homepage
    #haml:homepage 
    #view of posts list, search abilities: 
	# date selection
	# tag selection
    #click on a post's title (or a "more..." link)
	#--> redirects to /viewPost with id=the selected
  end

  get "/viewPost" do
    #here we see the whole content of a post
    #in :params somehow we ll have the id of a post to show 
    #haml:viewPost
    #containing the form for comment submition
      #{:action => "/viewPost", :method => "post"}
   #AND a browse link -->redirects to /browsePosts
    
  end

  post "/viewPost" do 
    # comment addition information and ok button --> get '/viewPost'
  end


  get "/login" do
    #haml:loginform
    #a form
    #containing username password textfields
    #submiting {:action => "/login", :method => "post"}
  end

  post "/login" do
    # authentication using the params by loginform
    #--> if ok admin part accessible & redirect to /admin
    # for start I keep them accessible to all
  end

  #***********************************************	
  # we will add later a before "/admin/*" block
  # so as to check the authentication of the user each time 
  # one of the adnim part's page  is accessed
  #************************************************

  get "/admin" do
    #haml:controlpanel
    #contains links which redirect to newPost and browsePosts (for start)
  end

  get "/admin/newPost" do 
    haml:newPost
    #a form
    #containing textfields for the new post data
    #submiting {:action => "/admin/newPost", :method => "post"}
  end
	
  post "/admin/newPost" do    
	#edw tha eixa ton loggedin user kai tha ekana add post
		#dinontas mono title kai content
	newpost = Post.create( :user_id => 1, :title => params[:title] , :content => params[:content])	
	"Post created"
	redirect to("/admin/viewPost?postid=#{newpost.id}")
# reply & if ok redirect to admin/post
# with id=last created			
  end
  	
  get "/admin/browsePosts" do
    #haml:allPosts
    #view of posts list, search abilities...??? 
    #multiple forms:
    #link for new post --> get '/admin/newPost'
    #click on a post's title--> redirects to admin/viewPost
		# with id=the selected

  end
  

  get "/admin/viewPost" do
	#postid=params[postid]
	"You now should view post with title #{params[:postid]}"
    #here is the editpost page
    #in :params somehow we ll have the id of a post to show 
    #haml:editPost
    #containing save button for changes -->stay in page 
#-->form submitting :action => "/admin/savePost", method => :post
	#delete button -->deletes current and redirects to allPosts 
#--> form submitting "/admin/deletePost", method => :post
	#browse link -->redirects to /admin/browsePosts

    #later add ability for taging
  end
  
  post "/admin/savePost" do
     #saving reply with ok which just redirects to admin/viewPost
  end

  post "/admin/deletePost" do
    #deletion reply with ok which just redirects to admin/browsPosts
  end   


end

