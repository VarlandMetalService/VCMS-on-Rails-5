class FlaggedRecordMailer < ApplicationMailer
  default from: 'varlandmetalservice@gmail.com'

  def flagged_record_email(record, notes)
    @user = record.user
    @record_timestamp = record.record_timestamp
    @record_type = record.record_type
    @notes = notes
    mail(to: get_supervisor(record.user.employee_number), subject: 'Employee Flagged Timeclock Record')
  end

private
  def get_supervisor(employee_number)
    'brendan.ryan@varland.com'
    # if employee_number >= 600
    #   ['gail.krauser@varland.com']
    # elsif employee_number >= 400
    #   ['greg.turner@varland.com', 'terry.marshall@varland.com']
    # elsif employee_number >= 300
    #   ['brian.mangold@varland.com']
    # elsif employee_number >= 200
    #   ['ted.mckeehan@varland.com', 'cliff.queen@varland.com']
    # else
    #   ['vmsforemen@gmail.com']
    # end
  end
end
