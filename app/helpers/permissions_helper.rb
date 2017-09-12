module PermissionsHelper

  def user_name_for id = false
    return '' unless id
    begin
      u = User.find(id)
      u.full_name
    rescue
      ''
    end
  end
  
end
