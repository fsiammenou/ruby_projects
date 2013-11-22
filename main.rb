
class App < Sinatra::Application
  
  configure do
    set :db, DB = Sequel.sqlite('db/data.db')
    set :sessions => true
  end

  register do
    def auth(parm)
      condition do
        redirect "/login" unless is_userloggedin?
      end
    end
  end

  #*********************************************** 
  # Helpers
  #***********************************************

  helpers do
    #customize the date format
    def dformat(a)
      if a != nil 
        a.strftime("%d %b %Y")
      end
    end

    #returns the details for a user stored in users table
    def get_user(user_id)
      User.filter(:id => user_id).limit(1).all[0]
    end

    #returns comments
    def get_comments(post_id)
      Comment.filter(:post_id => post_id, :status => 1).all
    end

    #used for gravatar
    def md5(str)
      Digest::MD5.hexdigest(str)
    end

    #defines the length of the excerpt and strips tags
    def excerpt(str, length = 380)
      str.gsub(/<\/?[^>]*>/, "")[0, length]
    end

    #returns the "three" most recent posts
    def recent_posts(num = 3)
      Post.filter(:status => 1).limit(num).order(:date_created).reverse
    end

    #returns the number of posts for all user or for a specific one
    def get_num_of_posts(user_id = false)
      if user_id != false
        (Post.filter(:user_id => user_id, :status => 1).all).length
      else
        (Post.filter(:status => 1).all).length
      end
    end

    #used to construct the pagination
    def get_num_of_pages
      ((get_num_of_posts.to_f / 5).ceil).to_i
    end
   
    #returns if user is loggedin or not
    def is_userloggedin?
      @loggedinuser != nil
    end
  end

  #*********************************************** 
  # End helpers
  #***********************************************

  #Stores sessions
  before do
    if session[:user_id] == nil then 
       @loggedinuser = nil
    else
       @loggedinuser = User[session[:user_id]]
    end
  end

  #Error page
  not_found { haml :'404' }

  #*********************************************** 
  # Begin public part
  #***********************************************

  #Homepage which contains the list of posts from newest to oldest
  get '/' do
    @posts = Post.filter(:status => 1).limit(5).order(:date_created).reverse

    haml :postsList
  end

  #Search results page
  post '/search' do
    @posts = Post.filter(Sequel.like(Sequel.function(:lower, :title), "%#{params[:search]}%"), :status => 1).all

    haml :search
  end

  #Archives page
  get '/archives/:year/:month/:day' do
    @date = "#{params[:year]}-#{params[:month]}-#{params[:day]}"
    @posts = Post.where(Sequel.like(:date_created, "#{@date}%"), :status => 1).all

    haml :search
  end

  #Pagination
  get '/page/:page' do
    if (params[:page]) and ( (params[:page].to_i) == 1)
      redirect "/"
    elsif (params[:page]) and ( (params[:page].to_i) <= get_num_of_pages.to_i )
      @num = ( ( ((params[:page]).to_i) - 1) * 5).to_i
      @posts = Post.filter(:status => 1).limit(5).offset(@num).order(:date_created).reverse
    else
      redirect "/"
    end
    
    haml :postsList
  end

  #Single post
  get '/post/:id/view' do
    @post = Post.filter(:id => params[:id]).limit(1).all[0]

    haml :postView
  end

  #Post a comment
  post '/post/:id/comment' do
    comment = Comment.create(:post_id => params[:id], :author => params[:name], :author_email => params[:email], :author_ip => request.env['REMOTE_ADDR'], :date => DateTime.now, :content => params[:message])

    redirect "/post/#{params[:id]}/view"
  end

  #*********************************************** 
  # End public part
  #***********************************************

  #*********************************************** 
  # Begin admin part
  #***********************************************

  #Login page
  get "/login" do
    if session[:user_id] != nil
      redirect to "/admin"
    end
    haml :login
  end

  #Authentication
  post "/login" do
    if (params[:username] != nil or params[:password] != nil)
      userfound = User.filter(:username => params[:username], :password => params[:password], :status => 1).limit(1).all

      if !userfound.to_a.empty? then
        session[:user_id] = userfound[0].id
        redirect to "/admin"
      end
    end
      session[:user_id] = nil
      @msg = "Username or password is wrong!"

      haml :login
  end

  #Logout
  get "/logout" do
    session[:user_id] = nil
    redirect to "/login"
  end

  #Dashboard
  get "/admin", :auth => :user do
    haml :dashboard
  end

  #Delete via Ajax
  post "/admin/delete", :auth => :user do
    @id = params[:id]
    @table = params[:action]

    case params[:action]
    when 'user'
      dataset = User
    when 'post'
      dataset = Post
    when 'comment'
      dataset = Comment
      post_edited = Post[:id => Comment.filter([:id => @id]).limit(1).all[0][:post_id]]
    when 'tag'
      dataset = Tag
    end

    if dataset.where(:id => @id).delete
      @output = {:info => "success", :redirect => request.referer.split('?').first + "?msg=success"}

      if params[:action] == 'comment'
        post_edited.comment_count = ((post_edited.comment_count).to_i - 1).to_i
        post_edited.save
      end
    else 
      @output = {:info => "error", :redirect => request.referer.split('?').first + "?msg=error"}
    end

    require 'json'

    @output.to_json
  end

  #List of posts
  get "/admin/post/all", :auth => :user do
    @posts = Post.all
    haml :posts
  end

  #Add new post page
  get "/admin/post/new", :auth => :user do
    haml :newpost
  end

  #Save post
  post "/admin/post/save", :auth => :user do
    @title = params[:title]
    @content = params[:content]
    @date_created= DateTime.now
    @date_modified = DateTime.now
    @status = params[:status]

    @type = params[:type]

    @tags = params[:tags]

    case @type
    when 'standard'
      if params[:myfile] and (params[:myfile][:filename] and (params[:myfile][:filename] != nil))
        File.open('public/uploads/' + params[:myfile][:filename], "w") do |f|
          f.write(params[:myfile][:tempfile].read)
        end
      
        @filename = params[:myfile][:filename]
      end
    when 'video'
      @filename = params[:video_url]
    when 'audio'
      @filename = params[:audio_url]
    else
      @filename = ""
    end

    if params[:action] == 'save'
      newpost = Post.create(:user_id => @loggedinuser.id, :title => @title, :content => @content, :date_created => @date_created, :date_modified => @date_modified, :status => @status, :type => @type, :comment_count => 0, :filename => @filename)

      redirect("/admin/post/#{newpost.id}/edit?msg=success")
    elsif params[:action] == 'edit' && params[:id]
      post_edited = Post[params[:id]]
      post_edited.title = params[:title]
      post_edited.content = params[:content]
      post_edited.date_modified = DateTime.now
      post_edited.status = params[:status]
      post_edited.type = params[:type]
      if (@filename != "") and (@filename != nil)
        post_edited.filename = @filename
      end
      post_edited.save

      redirect("/admin/post/#{post_edited.id}/edit?msg=success")
    end

    haml :newpost
  end

  #Edit post
  get "/admin/post/:id/edit", :auth => :user do
    @id = params[:id]
    @post = Post.filter(:id => @id).limit(1).all[0]
    haml :newpost
  end

  #List of comments including approved and unapproved ones
  get "/admin/comments", :auth => :user do
    @comments_approved = Comment.filter(:status => 1).all
    @comments_unapproved = Comment.filter(:status => nil).all
    haml :comments
  end

  #Edit comment
  get "/admin/comment/:id/edit", :auth => :user do
    @id = params[:id]
    @comment = Comment.filter(:id => @id).limit(1).all[0]
    haml :editComment
  end

  #Save comment
  post "/admin/comment/save", :auth => :user do
    comment_edit = Comment[params[:id]]
    comment_edit.author = params[:author]
    comment_edit.author_email = params[:author_email]
    comment_edit.content = params[:comment]
    @old_status = comment_edit.status
    comment_edit.status = params[:status]
    comment_edit.save

    post_edited = Post[comment_edit.post_id]

    if !params[:status] and (@old_status != nil)
      post_edited.comment_count = ((post_edited.comment_count).to_i - 1).to_i
    elsif params[:status] and (@old_status == nil)
      post_edited.comment_count = ((post_edited.comment_count).to_i + 1).to_i
    else
      post_edited.comment_count = (post_edited.comment_count).to_i
    end

    post_edited.save

    redirect "/admin/comments"
  end

  #List of users
  get "/admin/users", :auth => :user do
    @users = User.all

    haml :users
  end

  #New user
  get "/admin/user/new", :auth => :user do
    haml :newuser
  end

  #Edit user
  get "/admin/user/:id/edit", :auth => :user do
    @id = params[:id]
    @user = User.filter(:id => @id).limit(1).all[0]

    haml :newuser
  end

  #Save user
  post "/admin/user/save", :auth => :user do
    @username = params[:username]
    @first_name = params[:first_name]
    @last_name = params[:last_name]
    @email = params[:email]
    @password = params[:password]
    @description = params[:description]
    @status = params[:status]
    @level = params[:level]

    @date_registered = Time.now

    if params[:action] == 'save'
      newuser = User.create(:username => @username, :first_name => @first_name, :last_name => @last_name, :email => @email, :password => @password, :description => @description, :level => @level, :date_registered => @date_registered, :status => @status)

      redirect("/admin/user/#{newuser.id}/edit?msg=success")
    elsif params[:action] == 'edit' && params[:id]
      user_edited = User[params[:id]]
      user_edited.username = params[:username]
      user_edited.first_name = params[:first_name]
      user_edited.last_name = params[:last_name]
      user_edited.email = params[:email]
      user_edited.password = params[:password]
      user_edited.description = params[:description]
      user_edited.status = params[:status]
      user_edited.level = params[:level]
      user_edited.save

      redirect("/admin/user/#{user_edited.id}/edit?msg=success")
    end

    haml :newuser
  end

  #*********************************************** 
  # End admin part
  #***********************************************

end