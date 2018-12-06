class SaltSprayMailer < ApplicationMailer
  default from: 'varlandmetalservice@gmail.com'

  def salt_spray_email(test, notify_management, notify_sales)
    @test = test
    mail(to: get_email_list(notify_management, notify_sales), subject: 'Salt Spray Test Updated')
  end

private
  def get_email_list(notify_management, notify_sales)
    email_list = ['toby.varland@varland.com']

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