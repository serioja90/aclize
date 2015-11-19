
module Aclize
  module Helper
    def aclized?
      true
    end

    # Check if the user have permission to access the action
    def action_allowed?(controller, action)
      actions_allowed?(controller, [action], :all)
    end


    # Returns a boolean that indicates if the current used have enought permissions to access the
    # specified list of actions. The policy argument indicates the type of verification. By default,
    # its value is :all, that means the all the actions passed as argument have to be allowed. If the
    # policy if :any, is sufficient that at least one of the specified actions to be allowed.
    def actions_allowed?(controller, actions = [], policy = :all)
      acl = @_aclize_acl[:controllers]
      # If there's an entry for this controller in @acl, use that rule for permissions check.
      # Otherwise, check if there's an '*' entry if @acl and use that rules.
      methods = ( acl[controller.to_s] || acl['*'] || {} )
      allow   = methods["allow"] || []
      deny    = methods["deny"]  || []

      # If the array of methods is empty, the controller isn't allowed
      return false if allow.empty?

      # Force the list of actions to be an Array of strings
      normalized_actions = (actions.is_a?(Array) ? actions : [actions]).map{|action| action.to_s }

      # If all the methods of the current controller are allowed or the list of actions to check is empty, return true
      return true if (allow.include?("*") && (deny & normalized_actions).empty?) || normalized_actions.empty?

      case policy.to_sym
      when :all then return (deny & normalized_actions).empty? && (allow & normalized_actions == normalized_actions) # all the actions have to be allowed
      when :any then return !((allow & normalized_actions) - deny).empty?                                            # at least one action have to be allowed
      else
        logger.warn "Invalid policy: #{policy}."
        return false
      end
    end


    # Verify if the path could be accessed by the user. Returns true when
    # the path is accessible
    def path_allowed?(path)
      paths = @_aclize_acl[:paths]

      (paths[:deny] || []).each do |filter|
        return false if !path.match(Regexp(filter)).nil?
      end

      (paths[:allow] || []).each do |filter|
        return true if !path.match(Regexp(filter)).nil?
      end

      return false
    end
  end
end