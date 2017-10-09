module SaltSprayTestsHelper

  def reporters_for_select
    # TODO: Limit this list to only Salt Spray Test reporters
    User.all.collect {|u| [ u.full_name, u.id ]}
  end

end
