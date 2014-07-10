require "sinatra"
require "active_record"
require "./lib/database_connection"
require "rack-flash"


class App < Sinatra::Application
  enable :sessions
  use Rack::Flash

  def initialize
    super
    @database_connection = DatabaseConnection.new(ENV["RACK_ENV"])
  end

  get "/" do
    if session[:id]
      cur = @database_connection.sql("SELECT username FROM users WHERE id = #{session[:id]}")[0]["username"]
      if params[:sorted]
        display = display_sort(cur)
      else
        display = display_users(cur)
      end
      erb :loggedin, :locals => {:cur_user => cur, :users => display, :fish => display_fish(session[:id])}
    else
      erb :loggedout
    end
  end

  post "/" do
    id = @database_connection.sql("SELECT id FROM users WHERE username = '#{params[:username]}'").last["id"]
    session[:id] = id
    redirect "/"
  end

  post "/register" do
    check_register(params[:username], params[:password])
  end

  get "/register" do
    erb :register
  end

  get "/logout" do
    session.delete(:id)
    redirect "/"
  end

  delete "/:id" do
    name = get_name(params[:id])
    flash[:notice] = "#{name} deleted"
    @database_connection.sql("DELETE from users WHERE id = #{params[:id]}")
    redirect "/"
  end

  get "/new_fish" do
    erb :new_fish
  end

  post "/new_fish" do
    @database_connection.sql(
      "INSERT INTO fish (name, author) VALUES
      ('#{params[:fish_name]}',
      '#{session[:id]}')"
      )
    redirect "/"
  end

  get "/:author" do
    id = params[:author].to_i
    erb :user, :locals => {:name => get_name(id), :fish => display_fish(id)}

  end

  private

  def check_register(username, password)
    begin
      @database_connection.sql("INSERT INTO users (username, password) VALUES ('#{username}', '#{password}')")
    rescue => e
      if e.message.include?("userexists")
        flash[:notice] = "Username already exists"
      elsif password == '' && username == ''
        flash[:notice] = "Username and password are required"
      elsif username == ''
        flash[:notice] = "Username is required"
      elsif password == ''
        flash[:notice] = "Password is required"
      end
      redirect "/register"
    else
      flash[:notice]= "Thank you for registering"
      redirect "/"
    end
  end

  def display_users(username)
    @database_connection.sql("SELECT * FROM users where username <> '#{username}'")
  end

  def display_sort(username)
    @database_connection.sql("SELECT * FROM users where username <> '#{username}' order by username")
  end

  def get_name(id)
    @database_connection.sql("SELECT username FROM users where id = #{id}")[0]["username"]
  end

  def display_fish(id)
    @database_connection.sql(
      "SELECT fish.name, fish.id FROM fish
      inner join users on fish.author = users.id
      where author = #{id}")
  end
end





