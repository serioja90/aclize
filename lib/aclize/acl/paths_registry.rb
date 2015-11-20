
module Aclize
  class Acl::PathsRegistry

    attr_reader :permitted, :denied

    def initialize
      @permitted = []
      @denied    = []
    end

    def permit(*paths)
      @permitted += normalize(paths)
      @permitted.uniq!
    end

    def deny(*paths)
      @denied += normalize(paths)
      @denied.uniq!
    end

    protected

    def normalize(items)
      return items.nil? ? [] : items.is_a?(Array) ? items : [items]
    end
  end
end