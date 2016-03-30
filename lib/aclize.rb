require "aclize/version"
require "aclize/acl"
require "aclize/helper"
require "i18n"
require "action_controller"

module Aclize

  def self.included(base)
    base.extend ClassMethods
    base.send :prepend, Initializer
  end


  # The ClassMethods module will implement the methods that we want to be accessible as
  # class methods. This will permit to setup callbacks to execute on unauthorized access.
  module ClassMethods
    def aclized?
      true
    end

    def if_unauthorized(&block)
      if block_given?
        before_filter do
          register_callback(&block)
        end
      end
    end
  end


  # The Initializer module will be used to initialize instance variables and to setup defaults.
  module Initializer
    def initialize
      @_aclize_acl ||= Aclize::Acl.new
      @_aclize_current_role = nil
      super
    end
  end

  protected

  # Returns the ACL definition
  def get_acl_definition
    return @_aclize_acl
  end


  def set_current_role(role)
    @_aclize_current_role = role
  end

  def get_current_role
    return @_aclize_current_role || :all
  end


  # setup the ACL for a role
  def acl_for(role = :all, &block)
    @_aclize_acl.setup(role, &block)
  end


  # apply the ACL for a specific role and unauthorize if the user is not permitted
  # to access controller action or the path
  def treat_as(role)
    acl  = @_aclize_acl.get_acl_for(role)
    path = request.path.gsub(/^#{relative_url_root}/, '')
    unauthorize! unless acl

    if acl.controllers.permitted?(controller_path, action_name)
      unauthorize! if acl.paths.denied?(path)
    else
      unauthorize! unless acl.paths.permitted?(path)
    end
  end


  # use the current_role value to apply ACL
  def filter_access!
    treat_as get_current_role
  end


  # In no callbacks were defined for unauthorized access, Aclize will render a
  # default 403 Forbidden page. Otherwise, the control will be passed to the callback.
  def unauthorize!
    path = request.path
    flash.now[:alert] = I18n.t("aclize.unauthorized", path: path)

    if @_aclize_callback.nil?
      prepend_view_path File.expand_path("../../app/views", __FILE__)
      respond_to do |format|
        format.html { render 'aclize/403', disposition: "inline", status: 403, layout: false }
      end
    else
      self.instance_eval(&@_aclize_callback)
    end
  end

  # register a callback to call when the user is not authorized to access the page
  def register_callback(&block)
    @_aclize_callback = block
  end
end

I18n.load_path += Dir[File.expand_path("../../config/locales/*.{rb,yml}", __FILE__)]

class ActionController::Base
  include Aclize
end

module ApplicationHelper
  include Aclize::Helper
end
