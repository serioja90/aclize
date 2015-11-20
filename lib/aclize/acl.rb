
module Aclize
  class Acl
    require "aclize/acl/role"

    attr_reader :roles

    def initialize
      @roles = {
        all: Aclize::Acl::Role.new(:all)
      }.nested_under_indifferent_access
    end

    def setup(role, &block)
      @roles[role] ||= Aclize::Acl::Role.new(role)
      @roles[role].setup(&block)
    end
  end
end