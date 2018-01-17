module SaltSprayTestsHelper

  def reporters_for_select
    User.all.collect {|u| [ u.full_name, u.id ]}
  end

  def has_attachments(record)
    record.comments.any? {|comment| comment.attachments.size > 0}
  end

  def has_comments(record)
    record.comments.present?
  end

  def filter_path
    action_name == 'archived_tests' ?  archived_tests_salt_spray_tests_url : salt_spray_tests_url
  end

  def sorted_by_options
    if action_name == 'archived_tests'
      @salt_spray_tests.options_for_archived_sorted_by
    else
      @salt_spray_tests.options_for_sorted_by
    end
  end

  def flag_test_text
    if @salt_spray_test.flagged_by
      'Remove Flag'
    else
      'Flag For Editing'
    end
  end

end
