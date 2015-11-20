
module Aclize
  class Acl::Role
    require "aclize/acl/controllers_registry"
    require "aclize/acl/paths_registry"

    def initialize(name)
      @name        = name.to_s
      @controllers = Aclize::Acl::ControllersRegistry.new
      @paths       = Aclize::Acl::PathsRegistry.new
    end

    def controllers
      if block_given?
        @controllers.setup do |registry|
          yield registry
        end
      else
        return @controllers
      end
    end

    def setup
      yield self
    end
  end
end