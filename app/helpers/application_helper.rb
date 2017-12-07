module ApplicationHelper

  def format_line_breaks text
    text.gsub(/\r\n/, '<br />').html_safe
  end

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

  def primary_nav_link controller, action, text
    content_tag :li, class: (params[:controller] == controller && params[:action] == action ? 'active' : nil) do
      link_to text, { controller: controller, action: action }, class: 'dropdown-item'
    end
  end

  def access_level(right)
    current_user.permissions.find_by_permission right
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

  def department_name(dept)
    case dept
      when ''
        ''
      when nil
        ''
      when 30
        'Waste Water'
      else
        "Dept. #{dept}"
    end
  end

  def show_attachment attachment
    case attachment.content_type
      when 'image/jpeg'
        link_to(image_tag(attachment.file.thumb.url, class: 'img-fluid'), attachment.file.url, target: '_blank')
      when 'image/gif'
        link_to(image_tag(attachment.file.thumb.url, class: 'img-fluid'), attachment.file.url, target: '_blank')
      when 'image/png'
        link_to(image_tag(attachment.file.thumb.url, class: 'img-fluid'), attachment.file.url, target: '_blank')
      when 'video/quicktime'
        #video_tag attachment.file.url, class: 'img-fluid', controls: 'true', type: 'video/mp4'
        link_to "<i class=\"fa fa-file-video-o\"></i> #{attachment.file_identifier}".html_safe, attachment.file.url, target: '_blank'
      when 'video/mp4'
        video_tag attachment.file.url, class: 'img-fluid', controls: 'true', type: 'video/mp4'
        #link_to "<i class=\"fa fa-file-video-o\"></i> #{attachment.file_identifier}".html_safe, attachment.file.url, target: '_blank'
      when 'application/pdf'
        link_to "<i class=\"fa fa-file-pdf-o text-danger\"></i> #{attachment.file_identifier}".html_safe, attachment.file.url, target: '_blank'
      when 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
        link_to "<i class=\"fa fa-file-excel-o text-success\"></i> #{attachment.file_identifier}".html_safe, attachment.file.url
      when 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
        link_to "<i class=\"fa fa-file-word-o text-primary\"></i> #{attachment.file_identifier}".html_safe, attachment.file.url
      when 'application/zip'
        link_to "<i class=\"fa fa-file-archive-o\"></i> #{attachment.file_identifier}".html_safe, attachment.file.url
      else
        link_to "<i class=\"fa fa-file-o\"></i> #{attachment.file_identifier}".html_safe, attachment.file.url
    end
  end

  def show_attachment_email attachment
    link_to "#{attachment.file_identifier}".html_safe, "http://vcms.varland.com#{attachment.file.url}", target: '_blank'
  end

  def format_date(date)
    date ? date.strftime('%m/%d/%Y') : ''
  end

  def format_datetime_local(value)
    value ? value.strftime("%Y-%m-%dT%H:%M:%S.%L") : ''
  end

  def current_local_time
    DateTime.current.localtime.strftime('%l:%M %P')
  end

  def filter_btn
    "<button class='btn btn-sm btn-warning display-filter'>Show Filter</button>".html_safe
  end

end
