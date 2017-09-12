module ApplicationHelper

  def bootstrap_class_for flash_type
    case flash_type
      when 'success'
        'alert-success'
      when 'error'
        'alert-danger'
      when 'alert'
        'alert-warning'
      when 'danger'
        'alert-warning'
      when 'notice'
        'alert-info'
      else
        flash_type.to_s
    end
  end

  def primary_nav_link controller, action, text, reset_filterrific = false
    content_tag :li, class: (params[:controller] == controller && params[:action] == action ? 'active' : nil) do
      # if reset_filterrific
      #   content_tag :a, text, href: reset_filterrific_url(controller: controller, action: action)
      # else
        link_to text, { controller: controller, action: action }
      # end
    end
  end

  def full_title(page_title = '')
    base_title = 'VCMS'
    if page_title.empty?
      base_title
    else
      "#{page_title} | #{base_title}"
    end
  end

  def avatar_for(user, size = 32)
    "<img class=\"avatar\" src=\"holder.js/#{size}x#{size}?text=#{user.initials}&bg=#{user.background_color}&fg=#{user.text_color}\" title=\"#{user.full_name}\" />".html_safe
  end

  def required_field_label(text)
    "#{text} <sup><i class=\"fa fa-asterisk text-danger\"></i></sup>".html_safe
  end

end
