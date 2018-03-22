# Redmine operations

Some helper classes to perform operations in Redmine using the [REST API](www.redmine.org/projects/redmine/wiki/Rest_api_with_ruby).

The Login class requires a file with login information in the same directory as the class itself. The file should contain login credentials for a user with admin rights, and have the following contents:

    base_url <full url of redmine webserver>
    user <user login id>
    password <user password>

Replace the contents of the arrowheads (and the arrowheads themselves) with the required information.

### Example usage

This snippet displays some example usage of the RedmineOperation class

    require './RedmineOperations'

    # create a new user
    ro.create_user( "login": "Johnny", "firstname": "John", "lastname": "Doe", "mail": "john.doe@example.com", "password": "123password")
    puts ro.get_user_id_by_mail("john.doe@example.com")      # get user by email and print out the information
    puts ro.get_user_id_by_login("Johnny")                   # get user by login and print out the information

    puts ro.get_groups                                    # get groups and print out the information
    ro.create_group("Johnny's group")                     # create a group

    ro.group_add_user_by_login("Johnny's group", "Johnny")  # add user to group with login id
    ro.group_remove_user_by_login("Johnny's group", "Johnny") # remove from the group by login id

    ro.delete_group_by_name("Johnny's group")                     # delete a group
    ro.delete_user_by_mail("john.doe@example.com")        # delete user by their email



Documentation of the methods in the `doc` folder.

## Todo

Lots...
