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

  def category_list cat, access_level

    if cat.children.length == 0 && cat.documents.length == 0
      return ''.html_safe
    end

    buttons = ''
    if access_level && access_level.access_level == 3
      buttons = '<span class="pull-right">'
      buttons += link_to('<i class="fa fa-fw fa-pencil"></i>'.html_safe, edit_category_path(cat))
      buttons += link_to('<i class="fa fa-fw fa-arrow-up"></i>'.html_safe, move_up_categories_path(id: cat), method: :post)
      buttons += link_to('<i class="fa fa-fw fa-arrow-down"></i>'.html_safe, move_down_categories_path(id: cat), method: :post)
      buttons += '</span>'
    end
    item = "<div class=\"card card-default category-card\"><div class=\"card-header\" data-toggle=\"collapse\" data-target=\".cat#{cat.id}\" style=\"cursor: pointer;\"><i class=\"fa fa-fw fa-folder\" aria-hidden=\"true\"></i> #{cat.name}#{buttons}</div>"
    if cat.children.length > 0
      item += "<div class=\"card-body collapse cat#{cat.id}\" >"
      cat.children.each do |child|
        item += category_list(child, access_level)
      end
      item += "</div>"
    end
    if cat.documents.length > 0
      item += "<div class=\"collapse cat#{cat.id}\">"
      cat.documents.order(document_updated_on: :desc).each do |doc|
        extra_info = ' <small class="text-muted">' + doc.document_updated_on.strftime('%m/%d/%y') + '</small>'
        item += link_to(content_type_icon(doc.content_type) + ' ' + doc.name + extra_info.html_safe, doc, :class => 'list-group-item')
      end
      item += "</div>"
    end
    item += "</div>"

    item.html_safe

  end

end
