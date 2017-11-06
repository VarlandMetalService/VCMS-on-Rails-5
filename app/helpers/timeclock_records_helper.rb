module TimeclockRecordsHelper

  def employee_groups
    [
      {name: 'Plating', min: 0, max: 199, count: 0},
      {name: 'Maintenance', min: 200, max: 299, count: 0},
      {name: 'Lab', min: 300, max: 399, count: 0},
      {name: 'Shipping/QC', min: 400, max: 499, count: 0},
      {name: 'Supervisors', min: 600, max: 799, count: 0},
      {name: 'Office', min: 800, max: 999, count: 0}
    ]
  end

  def get_record_class(record_type)
    case record_type
    when 'Start Work'
      return 'bg-success'
    when 'End Work'
      return 'bg-danger'
    when 'Start Break', 'End Break'
      return 'bg-warning'
    when 'Notes'
      return 'bg-active'
    end
  end

  def closable_periods_exist?
    Period.where('period_end_date < ? AND is_closed IS FALSE', Date.current).size > 0
  end

end
