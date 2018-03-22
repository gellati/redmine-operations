require 'net/https'
require 'uri'
require 'json'
require './Login'


# Class to handle operation with a Redmine server through its REST api
class RedmineOperations

  # Format of data to be sent over the HTTP connection. Now only JSON, could also be XML
  attr_accessor :format
  # Message content-type, to be set in message header
  attr_accessor :content_type
  # Url of the Redmine server
  attr_accessor :base_url
  # Username to access the server
  attr_accessor :user
  # Password to access the server
  attr_accessor :password

  # Initializes the class
  def initialize
    login =  Login.new
    @format = '.json'
    @content_type = "application/json"
    @base_url = login.base_url.to_s
    @user = login.user.to_s
    @password = login.password.to_s
  end

  # Creates a new group
  # Params:
  # +groupname+:: Name of group to be created
  def create_group(groupname)
    payload = { group: {name: groupname}}
    endpoint = '/groups'
    url = self.base_url.to_s + endpoint.to_s + self.format.to_s
    self.post_data(url, payload)
  end

  # Creates a new user
  # Params:
  # +login+:: Login name for new user
  # +firstname+:: User's first name
  # +lastname+:: User's last name
  # +mail+:: User's email address
  # +password+:: Password for login
  def create_user(userparams = {})
    # TODO input verification
#    puts userparams.to_s

#    begin userparams.fetch(:login) rescue KeyError
#      raise ArgumentError.new('User login name is required')
#    end
#    begin puts userparams.fetch(:firstname) rescue KeyError
#      raise ArgumentError.new('User first name is required') # if userparams.login.empty?
#    end
#    begin puts userparams.fetch(:lastname) rescue KeyError
#      raise ArgumentError.new('User last name is required')  # if userparams.lastname.to_s.empty?
#    end
#    begin puts userparams.fetch(:email) rescue KeyError
#      raise ArgumentError.new('User email is required') # if userparams.mail.to_s.empty?
#    end


#    if userparams.fetch(:login).empty? || userparams.fetch(:login).nil?
#      raise ArgumentError.new('User login name is required')
#    end

#    raise ArgumentError.new('User first name is required') if userparams.firstname.to_s.empty?

    if self.format == '.json'
      payload = { user: userparams}
    end
    endpoint = '/users'
    url = self.base_url.to_s + endpoint.to_s + self.format.to_s
    self.post_data(url, payload)
  end

  # Get a listing of current users
  def get_users
    endpoint = '/users/current'
    url = self.base_url.to_s + endpoint.to_s + self.format.to_s
    self.get_data(url)
  end

  # Get a listing of current users. duplicate method?
  def get_users
    endpoint = '/users'
    url = self.base_url.to_s + endpoint.to_s + self.format.to_s
    self.get_data(url)
  end

  # Get the user id with the login
  def get_user_id_by_login(login)
    users = self.get_users
    users["users"].select{|value| value["login"] == login }.first["id"]
  end

  # Get the user id with the mail
  # Params:
  # +mail+:: Email address of user
  def get_user_id_by_mail(mail)
    users = self.get_users
    users["users"].select{|value| value["mail"] == mail }.first["id"]
  end

  # Get a listing of groups
  def get_groups
    endpoint = '/groups'
    url = self.base_url.to_s + endpoint.to_s + self.format.to_s
    self.get_data(url)
  end

  # Get the id of the group by its name
  # Params:
  # +groupname+:: Name of the group
  def get_group_id_by_group_name(groupname)
    endpoint = '/groups'
    url = self.base_url.to_s + endpoint.to_s  + self.format.to_s
    response = self.get_data(url)
    response["groups"].select{|value| value["name"] == groupname }.first["id"]
  end

  # Get the users of the group by the group id
  # Params:
  # +id+:: Id of the group
  def get_group_user_ids_by_group_id(id)
    result = self.get_group_users(id)
    result["group"].select{|values| values["users"]}["users"].map{|v| v["id"]}
  end

  # Get group users names using the group name
  # Params:
  # +name+:: Name of the group
  def get_group_user_names_by_group_name(name)
    id = self.get_group_id_by_group_name(name)
    result = self.get_group_users(id)
    result["group"].select{|values| values["users"]}["users"].map{|v| v["name"]}
  end


  # Get group users using the group id
  # Params:
  # +id+:: Id of the group
  def get_group_users(id)
    endpoint = '/groups'
    user_query = '?include=users'
    url = self.base_url.to_s + endpoint.to_s  + "/" + id.to_s + self.format.to_s + user_query
    self.get_data(url)
  end

  # Get group using the group id
  # Params:
  # +id+:: Id of the group
  def get_group_by_id(id)
    endpoint = '/groups'
    url = self.base_url.to_s + endpoint.to_s + "/" + id.to_s  + self.format.to_s
    response = self.get_data(url)
  end

  # Add user to a group using the user's login name
  # Params:
  # +groupname+:: Name of the group
  # +login+:: User's login name
  def group_add_user_by_login(groupname, login)
    endpoint = '/groups'
    group_id = self.get_group_id_by_group_name(groupname)
    url = self.base_url.to_s + endpoint.to_s + "/" + group_id.to_s  + "/" + "users" + self.format.to_s
    new_user = self.get_user_id_by_login(login)
    if self.format == '.json'
      payload = { user_id: new_user }
    end
    self.post_data(url, payload)
  end

  # Remove user from a group using the user's login name
  # Params:
  # +groupname+:: Name of the group
  # +login+:: User's login name
  def group_remove_user_by_login(groupname, login)
    endpoint = '/groups'
    group_id = self.get_group_id_by_group_name(groupname)
    user = self.get_user_id_by_login(login)
    url = self.base_url.to_s + endpoint.to_s + "/" + group_id.to_s  + "/" + "users" + "/" + user.to_s + self.format.to_s
    self.delete_data(url)
  end

  # Delete a group using the group's name
  # Params:
  # +groupname+:: Name of the group
  def delete_group_by_name(groupname)
    endpoint = '/groups'
    id = self.get_group_id_by_group_name(groupname)
    url = self.base_url.to_s + endpoint.to_s + "/" + id.to_s + self.format.to_s
    self.delete_data(url)
  end

  # Delete a user using the email address
  # Params:
  # +mail+:: User's mail address
  def delete_user_by_mail(mail)
    id = self.get_user_id_by_mail(mail)
    self.delete_user_by_id(id)
  end

  # Delete a user using the login name
  # Params:
  # +login+:: Users login name
  def delete_user_by_login(login)
    id = self.get_user_id_by_login(login)
    self.delete_user_by(id)
  end

  # Delete a user using the id
  # Params:
  # +id+:: User's id
  def delete_user_by_id(id)
    endpoint = '/users'
    url = self.base_url.to_s + endpoint.to_s + "/" + id.to_s + self.format.to_s
    self.delete_data(url)
  end


  # Get data given an url
  # Params:
  # +url+:: url to fetch data from
  def get_data(url)
    uri = URI.parse(url)
    req = Net::HTTP::Get.new(uri.request_uri)
    req["Content-Type"] = self.content_type
    req.basic_auth(self.user.to_s, self.password.to_s)
    http = Net::HTTP.new(uri.host, uri.port)
    JSON.parse(http.request(req).body.to_s)
  end

  # Post data given an url. Used to create items
  # Params:
  # +url+:: url to fetch data from
  def post_data(url, payload)
    uri = URI.parse(url)
    req = Net::HTTP::Post.new(uri.request_uri)
    req["Content-Type"] = self.content_type
    req.basic_auth(self.user.to_s, self.password.to_s)
    req.body = payload.to_json
    http = Net::HTTP.new(uri.host, uri.port)
    response = http.request(req)
    puts response.code
    puts response.body
  end

  # Put data given an url. Used for updates
  # Params:
  # +url+:: url to fetch data from
  def put_data(url, payload)
    uri = URI.parse(url)
    req = Net::HTTP::Put.new(uri.request_uri)
    req["Content-Type"] = self.content_type
    req.basic_auth(self.user.to_s, self.password.to_s)
    req.body = payload.to_json
    http = Net::HTTP.new(uri.host, uri.port)
    response = http.request(req)
  end

  # Delete data given an url
  # Params:
  # +url+:: url to fetch data from
  def delete_data(url)
    uri = URI.parse(url)
    req = Net::HTTP::Delete.new(uri.request_uri)
    req["Content-Type"] = self.content_type
    req.basic_auth(self.user.to_s, self.password.to_s)
    http = Net::HTTP.new(uri.host, uri.port)
    http.request(req)
  end

end
