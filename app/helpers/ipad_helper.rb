module IpadHelper

  def action_buttons(employee_status)
    case employee_status
    when 'in'
      '<div class="form-group">
        <button class="btn btn-block btn-lg btn-danger end-work-button">
          <i class="fa fa-fw fa-wrench"></i> End Work
        </button>
      </div>

      <div class="form-group">
        <button class="btn btn-block btn-lg btn-warning start-break-button">
          <i class="fa fa-fw fa-cutlery"></i> Start Break
        </button>
      </div>'.html_safe
    when 'out'
      '<div class="form-group">
        <button class="btn btn-block btn-lg btn-success start-work-button">
          <i class="fa fa-fw fa-wrench"></i> Start Work
        </button>
      </div>'.html_safe
    when 'break'
      '<div class="form-group">
        <button class="btn btn-block btn-lg btn-primary end-break-button">
          <i class="fa fa-fw fa-cutlery"></i> End Break
        </button>
      </div>'.html_safe
    end
  end

end
