# The policy adopted by Aclize is:
#   1. By default all the controllers and paths are denied
#   2. On rules conflict, the more restrictive rule will be used
#   3. When permit and deny rules have the same restriction,
#      deny rule will be used


module Aclize
  class Acl::ControllersRegistry

    attr_reader :permitted, :denied

    def initialize
      @permitted = {"*" => []}.nested_under_indifferent_access
      @denied    = {"*" => []}.nested_under_indifferent_access
    end

    # add a new permit rule to controllers registry
    def permit(controller, only: nil, except: nil)
      @permitted[controller] ||= []
      @denied[controller]    ||= []

      raise ArgumentError.new("#permit cannot accept both :only and :except. At most one of them can be specified!") if only && except

      if except
        @permitted[controller] = ["*"]
        @denied[controller]    = normalize(except)
      elsif only
        @denied[controller]    = []
        @permitted[controller] = normalize(only)
      else
        @permitted[controller] = ["*"]
        @denied[controller]    = []
      end
    end

    # check if each action in the list is allowed for the specified controller
    def permitted?(controller, *args)
      @permitted[controller] ||= []
      @denied[controller]    ||= []
      actions = normalize(args)

      if actions.empty?
        return controller_permitted?(controller)
      elsif controller_permitted?(controller)
        # we know the there's at least one permitted action for this controller,
        # so return false if there's at least one denied action in the list of actions to check
        return false unless (actions & @denied[controller]).empty?

        # we know that the actions aren't denied at controller level, so we could
        # return true if all the actions are also permitted at controller level
        return true if @permitted[controller].include?("*") || (actions & @permitted[controller]) == actions

        # the actions aren't permitted at controller level, so if any of them is
        # denied at global level, we will return false
        return false unless (actions & @denied["*"]).empty?

        # the actions aren't denied at global level, so we have to check if them
        # are allowed at global level and return true if so
        return true if @permitted["*"].include?("*") || (actions & @permitted["*"]) == actions
      end

      return false
    end

    protected

    # check if the controller is permitted (at least one action in the controller should be permitted)
    def controller_permitted?(controller)
      # the simplies case is when there's a permission for at least one action for this controller
      if @permitted[controller].empty?
        # check if there're wildcard permissions
        if @permitted["*"].empty?
          # there isn't any global permission for the user
          return false
        else
          # we have global permissions (for all the controllers), so we
          # have to check if those actions weren't denied
          denied_actions = @denied[controller] + @denied["*"]
          return !(@permitted["*"] - denied_actions).empty?
        end
      else
        # we are sure there's at least one permission for this controller
        return true
      end
    end

    def normalize(items)
      result = items.nil? ? [] : items.is_a?(Array) ? items.flatten : [items]
      return result.map { |x| x.to_s }
    end
  end
end