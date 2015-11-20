
module Aclize
  class Acl::ControllersRegistry

    def initialize
      @permit = {}
      @deny   = {}
    end

    # add a new permit rule to controllers registry
    def permit(name, only: nil, except: nil)
      @permit[name.to_s] ||= []
      @deny[name.to_s]   ||= []

      if options.empty?
        @permit[name.to_s] << "*"
      elsif except
        @permit[name.to_s] << "*"
        @deny[name.to_s]   += normalize(except)
      elsif only
        @permit[name.to_s] += normalize(only)
      end
    end

    # add a new deny rule to controllers registry
    def deny(name, only: nil, except: nil)
      # deny is the oposite of permit, so it
      # is sufficient to invert :only with :except
      permit name, only: only, except: except
    end


    def setup
      yield self
    end


    protected

    def normalize(items)
      result = items.nil? ? [] : items.is_a?(String) ? [items] : items
      return result.map { |x| x.to_s }
    end
  end
end