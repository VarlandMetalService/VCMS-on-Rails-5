module SaltSprayTestsHelper

  def reporters_for_select
    # TODO: Limit this list to only Salt Spray Test reporters
    User.all.collect {|u| [ u.full_name, u.id ]}
  end

  def get_pass_fail(current_hours, spec)
    if current_hours <= spec
      return 'spec_passed'
    else
      return 'spec_failed'
    end
  end

end
