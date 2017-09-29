class DailyShiftNotesMailer < ApplicationMailer

  helper  :application

  default from: 'varlandmetalservice@gmail.com',
          to: ['Shift Notes Recipients <dailyshiftnotes@varland.com>']

  def send_author_supervisor_notes note
    @note = ShiftNote.find(note)
    mail(subject: 'Supervisor Commented on Shift Note',
          to: ["#{@note.author.full_name} <#{@note.author.email}>", "#{@note.supervisor.full_name} <#{@note.supervisor.email}>"])
  end

  def specific_note_email note, group
    @note = ShiftNote.find(note)
    recipient = nil
    case group
      when 'it'
        recipient = 'IT <it@varland.com>'
      when 'lab'
        recipient = 'Lab <lab@varland.com>'
      when 'maintenance'
        recipient = 'Maintenance <maint@varland.com>'
      when 'qc'
        recipient = 'QC <qcshiftnotes@varland.com>'
      when 'shipping'
        recipient = 'Shipping <shippingshiftnotes@varland.com>'
      else
        return
    end
    mail(subject: 'Shift Note Alert',
          to: recipient)
  end

  def daily_summary_email
    @yesterday = Date.today - 1
    @first_shift_notes = ShiftNote.with_date(@yesterday).with_shift(1).sorted_by('created_at')
    @second_shift_notes = ShiftNote.with_date(@yesterday).with_shift(2).sorted_by('created_at')
    @third_shift_notes = ShiftNote.with_date(@yesterday).with_shift(3).sorted_by('created_at')
    mail(subject: 'Daily Shift Notes Summary')
  end

end