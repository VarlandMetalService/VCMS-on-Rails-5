module SaltSprayTestsHelper

  def reporters_for_select
    # TODO: Limit this list to only Salt Spray Test reporters
    User.all.collect {|u| [ u.full_name, u.id ]}
  end

  def has_attachments(record)
    record.comments.any? {|comment| comment.attachments.size > 0}
  end

end
