
module Aclize
  class Acl::Role
    require "aclize/acl/controllers_registry"
    require "aclize/acl/paths_registry"

    def initialize(name)
      @name        = name.to_s
      @controllers = Aclize::Acl::ControllersRegistry.new
      @paths       = Aclize::Acl::PathsRegistry.new
    end

    def controllers(&block)
      if block_given?
        @controllers.instance_eval(&block)
      else
        return @controllers
      end
    end

    def paths(&block)
      if block_given?
        @paths.instance_eval(&block)
      else
        return @paths
      end
    end
  end
end