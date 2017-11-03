module IpadHelper

  def get_record_type(status)
    case status
    when 'in'
      'End Work'
    when 'out'
      'Start Work'
    when 'break'
      'End Break'
    end
  end

  def get_response_message(status, success)
    case status
    when 'in'
      if success
        "Successfully clocked out at #{current_local_time}."
      else
        "Failed to clock out. Please contact IT for help."
      end
    when 'out'
      if success
        "Successfully clocked in at #{current_local_time}."
      else
        "Failed to clock in. Please contact IT for help."
      end
    when 'break'
      if success
        "Successfully ended break at #{current_local_time}."
      else
        "Failed to clock back in from break. Please contact IT for help."
      end
    end
  end

  def get_icon(status)
    case status
    when 'in', 'out'
      'wrench'
    when 'break'
      'cutlery'
    end
  end

  def get_color(status)
    case status
    when 'in'
      'danger'
    when 'out'
      'success'
    when 'break'
      'primary'
    end
  end

end
