# Aclize #

[![Build Status](https://travis-ci.org/serioja90/aclize.svg)](https://travis-ci.org/serioja90/aclize)

__Aclize__ is a Ruby gem that allows you to easily define an ACL (Access Controll List) to controllers and paths of your Ruby on Rails application.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'aclize'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install aclize

## Usage

The __Aclize__ gem will automatically load and will wrap `ActionController::Base`, in order to allow you to define the ACL rules from inside of your `ApplicationController` or any other controller that inherits from it.

Here is an example of how to use __Aclize__ in your project:

```ruby
class ApplicationController < ActionController::Base
  before_filter :setup_acl

  protected

  def setup_acl

    # define ACL for :admin
    acl_for :admin do
      controllers do
        permit "*" # permit to access any action of any controller
      end
    end

    # define acl for :user
    acl_for :user do
      controllers do
        permit :posts, only: [:index, :show]                  # users can access only :index and :show actions of :posts controller
        permit :comments, except: [:edit, :update, :destroy]  # can also access all the actions of :comments controller, except for :edit, :update and :destroy actions
      end

      paths do
        permit "path/[a-c]", "path/[0-9]+"    # permit :user to access "path/a", "path/b", "path/c" and "path/<a digit>"
        deny   "path/b"                       # deny the access to "path/b"
      end
    end

    set_current_role(current_user.role) # assuming that current_user is returning an object representing the current user
    filter_access! # apply the ACL for the current user
  end
end
```

__IMPORTANT:__ you have to tell __Aclize__ what is the role of the current user by calling `set_current_role(<ROLE>)` method, because if you don't specify any role, the default role `:all` will be used.

Once you've defined the ACL, __Aclize__ will automatically manage the access control and will render the `403 Forbidden` page when the user doesn't have enough permissions to access it.

### Customizing 403 Page ###

If you need to customize the `403 Forbidden` page, you could use the `if_unauthorized` helper for storing a callback, that will be executed when the access was denied to a user:

```ruby
class ApplicationController < ActionController::Base
  if_unauthorized do
    respond_to do |format|
      format.html { render 'custom/403', disposition: 'inline', status: 403 }
    end
  end

  before_filter :setup_acl

  protected

  def setup_acl
    # YOUR ACL DEFINITION
  end
end
```


## Contributing

1. Fork it ( https://github.com/serioja90/aclize/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
