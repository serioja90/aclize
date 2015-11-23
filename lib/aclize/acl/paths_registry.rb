# The policy for paths ACLs is slightly different from the controllers policy, because
# on rules conflicts, the deny rule always wins. Here is a brief description of the policy:
#
# 1. By default all the paths are not permitted
# 2. On rule conflict, the deny rule always wins
# 3. A path is permitted only if there's an explicit permit rule

module Aclize
  class Acl::PathsRegistry

    attr_reader :permitted, :denied

    def initialize
      @permitted = []
      @denied    = []
    end


    # permit a new path
    def permit(*paths)
      @permitted += normalize(paths)
      @permitted.uniq!
    end


    # deny a path
    def deny(*paths)
      @denied += normalize(paths)
      @denied.uniq!
    end


    # Check if the paths are permitted. This method should return true
    # only if each path passed as argument is permitted (isn't denied and
    # have an explicit permission).
    def permitted?(*args)
      permitted = false

      # check if any of the paths is denied and return false if so
      @denied.each do |denied_path|
        args.each do |path|
          return false if path.match(/^#{denied_path}$/)
        end
      end

      # each path should have an explicit permission in order to return true
      args.each do |path|
        # we assume that the path isn't permitted
        permitted = false

        # iterate over permitted paths and check if any of them matches the current one
        @permitted.each do |permitted_path|
          permitted ||= !!path.match(/^#{permitted_path}$/)
          # stop iteration if the path is permitted
          break if permitted
        end
        #return false if the path isn't permitted
        return false unless permitted
      end

      return permitted
    end

    protected

    def normalize(items)
      return items.nil? ? [] : items.is_a?(Array) ? items.flatten : [items]
    end
  end
end