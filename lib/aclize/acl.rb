
module Aclize
  class Acl
    require "aclize/acl/role"

    def initialize
      @roles = {
        all: Aclize::Acl::Role.new(:all)
      }.nested_under_indifferent_access
    end

    def setup(role)
      @roles[role] ||= Aclize::Acl::Role.new(role)
      @roles[role].setup do
        yield
      end
    end
  end
end