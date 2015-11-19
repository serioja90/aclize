require "aclize/version"
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
      @_aclize_acl = {controllers: {}, paths: {} }.nested_under_indifferent_access
      super
    end
  end

  protected

  # Returns the ACL definition as a Hash
  def get_acl_definition
    return @_aclize_acl
  end

  # Defines the structure of ACL for the current user
  # TODO: implement a better or an alternative way for ACL definition
  def define_acl(acl)
    raise "Invalid ACL definition type: (expected: Hash, got: #{acl.class})" unless acl.is_a? Hash

    if acl.has_key?(:controllers) && acl[:controllers].is_a?(Hash)
      @_aclize_acl[:controllers] = acl[:controllers]
    end

    if acl.has_key?(:paths) && acl[:paths].is_a?(Hash)
      @_aclize_acl[:paths] = acl[:paths]
    end
  end


  # In no callbacks were defined for unauthorized access, Aclize will render a
  # default 403 Forbidden page. Otherwise, the control will be passed to the callback.
  def unauthorize!
    path = request.path_info
    flash.now[:alert] = I18n.t("aclize.unauthorized", path: path)

    if @_aclize_callback.nil?
      prepend_view_path File.expand_path("../../app/views", __FILE__)
      respond_to do |format|
        format.html { render 'aclize/403', disposition: "inline", status: 403, layout: false }
      end
    else
      @_aclize_callback.call(path)
    end
  end


  # Check if the current user have enough permissions to access the current controller/path
  def filter_access!
    unauthorize! if acl_action_denied? || acl_path_denied? || !(acl_action_allowed? || acl_path_allowed?)
  end


  # check if the current action is denied
  def acl_action_denied?
    actions = (@_aclize_acl[:controllers][controller_name] || @_aclize_acl[:controllers]["*"] || {})[:deny] || []
    actions.map!{|action| action.to_s }

    return actions.include?("*") || actions.include?(action_name)
  end


  # check if the current action is allowed
  def acl_action_allowed?
    actions = (@_aclize_acl[:controllers][controller_name] || @_aclize_acl[:controllers]["*"] || {})[:allow] || []
    actions.map!{|action| action.to_s }

    return actions.include?("*") || actions.include?(action_name)
  end


  # check if the current path is denied
  def acl_path_denied?
    paths  = @_aclize_acl[:paths][:deny] || []
    denied = false

    paths.each do |path|
      denied ||= !request.path_info.match(Regexp.new("^#{path}$")).nil?
      break if denied
    end

    return denied
  end


  # check if the current path is allowed
  def acl_path_allowed?
    paths  = @_aclize_acl[:paths][:allow] || []
    allowed = false

    paths.each do |path|
      allowed ||= !request.path_info.match(Regexp.new("^#{path}$")).nil?
      break if allowed
    end

    return allowed
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
