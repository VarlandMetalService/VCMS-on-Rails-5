# Preview all emails at http://localhost:3000/rails/mailers/flagged_record_mailer
class FlaggedRecordMailerPreview < ActionMailer::Preview
  def flagged_record_preview
    FlaggedRecordMailer.flagged_record_email(TimeclockRecord.first, 'test')
  end
end
