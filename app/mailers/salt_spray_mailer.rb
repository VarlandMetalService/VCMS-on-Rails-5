class SaltSprayMailer < ApplicationMailer
  default from: 'varlandmetalservice@gmail.com'

  def salt_spray_email(test, notify_management, notify_sales)
    @shop_order_number = test.shop_order_number
    @load_number = test.load_number
    @customer = test.customer
    @part = test.part_number
    @sub = test.sub
    @marked_white_at = test.marked_white_at
    @marked_white_by = test.marked_white_by
    @marked_red_at = test.marked_red_at
    @marked_red_by = test.marked_red_by
    @is_sample = test.is_sample
    @process_steps = test.salt_spray_process_steps
    @pulled_off_at = test.pulled_off_at
    @pulled_off_by = test.pulled_off_by
    mail(to: get_email_list(notify_management, notify_sales), subject: 'Salt Spray Test Updated')
  end

private
  def get_email_list(notify_management, notify_sales)
    email_list = []

    if notify_management
      email_list.push('joel.perrine@varland.com',
        'brian.mangold@varland.com',
        'mike.mitchell.jr@varland.com')
    end

    if notify_sales
      email_list.push('kevin.marsh@varland.com',
        'art.mink@varland.com',
        'john.mcguire@varland.com')
    end

    return email_list
  end
end