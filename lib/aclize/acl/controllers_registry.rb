
module Aclize
  class Acl::ControllersRegistry

    attr_reader :permitted, :denied

    def initialize
      @permitted = {}
      @denied    = {}
    end

    # add a new permit rule to controllers registry
    def permit(name, only: nil, except: nil)
      @permitted[name.to_s] ||= []
      @denied[name.to_s]    ||= []

      if except
        @permitted[name.to_s] = ["*"]
        @denied[name.to_s]    = normalize(except)
      elsif only
        @permitted[name.to_s] = normalize(only)
      else
        @permitted[name.to_s] = "*"
      end
    end

    # add a new deny rule to controllers registry
    def deny(name, only: nil, except: nil)
      # deny is the oposite of permit, so it
      # is sufficient to invert :only with :except
      permit name, only: only, except: except
    end

    protected

    def normalize(items)
      result = items.nil? ? [] : items.is_a?(Array) ? items : [items]
      return result.map { |x| x.to_s }
    end
  end
end