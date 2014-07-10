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
        if params[:sort]
          username_list = @database_connection.sql("SELECT username FROM users WHERE username <> '#{cur}' ORDER BY username ASC")
       else
        username_list = @database_connection.sql("SELECT username FROM users WHERE username <> '#{cur}'")
        end
      erb :loggedin, :locals => {:cur_user => cur, :list => username_list}
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


  private

  def check_register(username, password)

    begin
      @database_connection.sql("INSERT INTO users (username, password) VALUES ('#{username}', '#{password}')")
    rescue => e
      if password == '' && username == ''
        flash[:notice] = "Username and password are required"
        redirect "/register"
      elsif username == ''
        flash[:notice] = "Username is required"
        redirect "/register"
      elsif password == ''
        flash[:notice] = "Password is required"
        redirect "/register"
      elsif e.message.include?("userexists")
      flash[:notice] = "Username already exists"
      redirect "/register"
      end
    else
      flash[:notice]= "Thank you for registering"
      redirect "/"
    end
  end

end




