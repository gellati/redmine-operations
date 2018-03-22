
# This class reads in the login information from a file
# which contains the base url for the Redmine server and
# also login credrentials in plantext form

class Login
  # Url of the Redmine server
  attr_accessor :base_url
  # Username to access the server
  attr_accessor :user
  # Password to access the server
  attr_accessor :password

  # initialize class with starting values
  def initialize
    login = self.read_login_data
    @base_url = login['base_url']
    @user = login['user']
    @password = login['password']
  end

  # Read login data and server address from file with name "login.data"
  def read_login_data
    login_data_file = 'login.data'
    Hash[*File.read(login_data_file).split(/[ \n]+/)]
  end

end
