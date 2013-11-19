
class App < Sinatra::Application
  #we may add a setting for the error to be showm or not
  #and may use different configuration for users and programmers (us)
  #on the other hand
  configure do
    set :db, Sequel.sqlite('./db/data.db')
  end
  
  before "/admin" do
    protected!
  end
  before "/admin/*" do
    protected!
  end

  helpers do
    def dformat(a)
      if a==nil 
         ""
      else
        a.strftime("%d %b %Y")
      end
    end

    def protected!
      unless authorized?
        response['WWW-Authenticate'] = %(Basic realm="Access Restricted to authenticated users only")
        throw(:halt, [401, "Login required\n"])
        #redirect to "/login" 
        # kalytera se mia selida '/loginRequired' me link to /login
      end
    end

    def authorized?
      users=User.all
      @auth ||=  Rack::Auth::Basic::Request.new(request.env)
      if users.empty?    #default login me admin/admin
        @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == ['admin', 'admin']
      else
        authenicatedUser = false
        users.each do |u|
          authenicatedUser = @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == [u.username, u.password] 
          break if authenicatedUser ==true
        end
        authenicatedUser #this is returned 
      end
    end


  end 

  get '/' do
    haml:publicHome 
    # contain welcoming and 
    # links for login or to browsePosts (public homepage)		
  end

  get '/browsePosts' do
    #here will be the public homepage
    posts = Post.all #.order(:date_created).reverse
    if posts.empty? 
	"There are no posts!"
    else
       "There are saved posts!"
       haml:publicAllPosts, :locals=>{:posts=>posts}
        #output=''
	#posts.each do |p|
	#   output << "#{p.title} <br />"
	#end
        #return output
    end    
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
    "You now should view post with id #{params[:postid]}"
    if Post[params[:postid]] == nil
      "Post with id #{params[:postid]} not found"
    else
       post = Post[params[:postid]]
       com = Comment.filter(:post_id=>params[:postid]).all
       haml:publicViewPost, :locals=>{:thepost=>post, :pcomments=>com}
	
    end
  end

  post "/viewPost" do 
    if (params[:author]==nil or params[:comment]==nil)
      redirect to "/viewPost?postid=#{params[:postid]}"
    else
      Comment.create(:post_id=>params[:postid], :author=> params[:author],:comment=> params[:comment],:date_added=> DateTime.now)	
      redirect to "/viewPost?postid=#{params[:postid]}"
     end
    # comment addition information and ok button --> get '/viewPost'
  end


  get "/login" do
    haml:loginForm
    #a form
    #containing username password textfields
    #submiting {:action => "/login", :method => "post"}
  end

  post "/login" do
   if (params[:username]==nil or params[:password]==nil)
	"Please give username and password to Login"
   else
#does not work
     @auth ||=  Rack::Auth::Basic::Request.new(request.env)
     @auth.credentials[0]=params[:username]
     @auth.credentials[1]=params[:password]
     redirect to "/admin"
   end

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
    haml:adminHome
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
	newpost = Post.create( :user_id => 1, :title => params[:title] , :content => params[:content], :date_created => DateTime.now)	
	"Post created"
	redirect to("/admin/viewPost?postid=#{newpost.id}")
    # reply & if ok redirect to admin/post
    # with id=last created			
  end
  
	
  get "/admin/browsePosts" do
    posts = Post.all #.order(:date_created).reverse
    if posts.empty? 
	"There are no posts!"
    else
       "There are saved posts!"
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
       haml:editPost, :locals=>{:thepost=>post}
	
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
       postEdited.date_updated=DateTime.now
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

