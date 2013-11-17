
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
    haml:loginForm
    #a form
    #containing username password textfields
    #submiting {:action => "/login", :method => "post"}
  end

  post "/login" do
    # authentication using the params by loginform
    # dinw ta dothenta sto antikeino poy kanei to authentication
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
	newpost = Post.create( :user_id => 1, :title => params[:title] , :content => params[:content], :date_created => Date.today)	
	"Post created"
	redirect to("/admin/viewPost?postid=#{newpost.id}")
    # reply & if ok redirect to admin/post
    # with id=last created			
  end
  
	
  get "/admin/browsePosts" do
    posts = Post.all
    if posts.empty? 
	"There are no posts!"
    else
	output=''
       haml:allPosts, :locals=>{:posts=>posts}
        #output=''
	#posts.each do |p|
	#   output << "#{p.title} <br />"
	#end
        #return output
    end
  
    #haml:allPosts
    #view of posts list, search abilities...??? 
    #multiple forms:
    #link for new post --> get '/admin/newPost'
    #click on a post's title--> redirects to admin/viewPost
		# with id=the selected

  end
  

  get "/admin/viewPost" do
    "You now should view post with id #{params[:postid]}"
    if Post[params[:postid]] == nil
      "Post with id #{params[:postid]} not found"
    else
       post = Post[params[:postid]]
       haml:editPost, :locals =>{:id=>post.id,:title=>post.title,:content=>post.content}
	
    end
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
  
  post "/admin/viewPost" do
    if Post[params[:postid]] == nil
      "Post with id #{params[:postid]} not found"
    else
     if params[:submit] == 'Save'
       postEdited=Post[params[:postid]]
       postEdited.title=params[:title]
       postEdited.content=params[:content]
       postEdited.save
       "Post updated"
       redirect to("/admin/viewPost?postid=#{postEdited.id}")
     else
       if params[:submit] == 'Delete'	
         postToDelete=Post[params[:postid]]
         postToDelete.delete
         "Post deleted"
         redirect to("/admin")
       end
     end 
    end
  end

  post "/admin/deletePost" do
    if Post[params[:postid]].exists?
    	Post[params[:postid]].delete
    	haml:editPost
    else
	"Post with id #{params[:postid]} not found"
    end
  end   


end

