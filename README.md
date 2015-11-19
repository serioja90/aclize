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
    if current_user.admin?
      # setup the ACL for admin users
      define_acl({
        controllers: {
          "*" => { allow: ["*"] } # grant permissions to access any action of any controller
        }
      })
    else
      # setup the ACL for other users
      define_acl({
        controllers: {
          posts: {
            allow: ["index", "show"] # allow to access only #index and #show actions of PostsController
          }
        }
      })
    end

    filter_access!
  end
end
```

In the example above we asume that the user passed the authentication, so that we know the type of account the user has.

__N.B:__ When you define the ACL with `define_acl(...)` you're defining it only for the current user.

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
