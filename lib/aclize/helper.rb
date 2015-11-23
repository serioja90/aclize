
module Aclize
  module Helper
    def aclized?
      true
    end

    # Check if the user have permission to access the action
    def action_allowed?(controller, action)
      actions_allowed?(controller, [action])
    end


    # Returns a boolean that indicates if the current user have enought permissions to access the
    # specified list of actions.
    def actions_allowed?(controller, actions = [])
      acl = @_aclize_acl.get_acl_for(get_current_role)
      return acl.controllers.permitted?(controller, actions)
    end


    # Verify if the path could be accessed by the user. Returns true when
    # the path is accessible
    def path_allowed?(path)
      acl = @_aclize_acl.get_acl_for(get_current_role)
      return acl.paths.permitted?(path)
    end


    def get_current_role
      return @_aclize_current_role || :all
    end
  end
end