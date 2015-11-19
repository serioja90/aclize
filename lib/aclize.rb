require "aclize/version"

module Aclize
  def define_acl(acl)
    @_aclize_acl = acl
  end

  def unauthorize!
    path = request.path_info
    flash[:alert] = I18n.t("aclize.unauthorized", path: path)

    if @_aclize_callback.nil?
      prepend_view_path File.expand_path("../../app/views", __FILE__)
      respond_to do |format|
        format.html { render 'aclize/403', disposition: "inline", status: 403, layout: false }
      end
    else
      @_aclize_callback.call(path)
    end
  end


  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def if_unauthorized(&block)
      if block_given?
        before_filter do
          register_callback(&block)
        end
      end
    end
  end

  protected

  def filter_access!
    @_aclize_acl ||= {}
    @_aclize_acl = @_aclize_acl.nested_under_indifferent_access
    @_aclize_acl[:controllers] ||= {}
    @_aclize_acl[:paths]       ||= {}

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
      denied ||= !request.path_info.match(Regexp.new(path)).nil?
      break if denied
    end

    return denied
  end


  # check if the current path is allowed
  def acl_path_allowed?
    paths  = @_aclize_acl[:paths][:allow] || []
    allowed = false

    paths.each do |path|
      allowed ||= !request.path_info.match(Regexp.new(path)).nil?
      break if allowed
    end

    return allowed
  end


  # register a callback to call when the user is not authorized to access the page
  def register_callback(&block)
    @_aclize_callback = block
  end
end

if defined? I18n
  I18n.load_path += Dir[File.expand_path("../../config/locales/*.{rb,yml}", __FILE__)]
end

if defined? ActionController::Base
  class ActionController::Base
    include Aclize
  end
end

if defined? ApplicationHelper
  module ApplicationHelper
    # include Aclize::Helper
  end
end