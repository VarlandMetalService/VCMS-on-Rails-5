module DocumentsHelper

  def content_type_icon type
    case type
      when 'image/png', 'image/jpeg', 'image/jpg', 'image/gif', 'image/tiff'
        '<i class="fa fa-fw fa-file-image-o text-info"></i>'.html_safe
      when 'video/quicktime', 'video/mp4'
        '<i class="fa fa-fw fa-file-video-o text-info"></i>'.html_safe
      when 'google/spreadsheets'
        '<i class="fa fa-fw fa-file-excel-o text-success"></i>'.html_safe
      when 'application/pdf'
        '<i class="fa fa-fw fa-file-pdf-o text-danger"></i>'.html_safe
      when 'google/document'
        '<i class="fa fa-fw fa-file-word-o text-info"></i>'.html_safe
      else
        '<i class="fa fa-fw fa-file"></i>'.html_safe
    end
  end

end
