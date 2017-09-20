require 'rest-client'

class DocumentsController < ApplicationController

  before_action :set_document, only: [:edit, :update, :destroy, :show]
  before_action :check_user_permission
  skip_before_action :require_login

  def index

    @documents = Document.all.page(params[:page])
    @category = Category.new

    @all_categories = Category.top_level
    @most_recent = Document.not_excluded.reorder(document_updated_on: :desc).limit(5)

  end

  def create
    @document = Document.new document_params
    categories = params[:document][:category_ids].reject!(&:empty?)
    @document.categories = Category.find(categories) if categories
    @document.user = current_user
    if @document.save
      redirect_to documents_url, notice: "Successfully added <code>#{@document.name}</code>.".html_safe
    else
      redirect_to documents_url, flash: { error: 'Error adding document. Please contact IT.' }
    end
  end

  def show
  end

  def edit
  end

  def destroy
    if @document.destroy
      redirect_to documents_url, notice: 'Successfully deleted document.'
    else
      redirect_to documents_url, flash: { error: 'Error deleting document. Please contact IT.' }
    end
  end

  def update
    if @document.update document_params
      categories = params[:document][:category_ids].reject!(&:empty?)
      @document.categories = Category.find(categories) if categories
      @document.save
      redirect_to @document, notice: "Successfully updated #{@document.name}."
    else
      render :show
    end
  end

  def get_google_meta
    googleDocsURL = params[:url]
    begin
      response = RestClient.get 'https://script.google.com/macros/s/AKfycbxXLu_t6lEyYUpLQ3s5tcfQz-691nGEuOV-eK7tce5uTmcbToM/exec', params: { url: googleDocsURL }, accept: :json
      parsed = JSON.parse(response)
      if parsed['valid']
        googleResult = {
          :content_type => "google/#{parsed['type']}",
          :google_id => parsed['id'],
          :google_contents => parsed['contents'],
          :name => parsed['title'],
          :google_updated_at => Time.new,
          :is_valid => 'true'
        }
      else
        googleResult = {
          :content_type => '',
          :google_id => '',
          :google_contents => '',
          :name => '',
          :google_updated_at => '',
          :is_valid => 'false'
        }
      end
    rescue => e
      logger.debug("ERROR (DocmentsController - get_google_meta): #{e.message}")
      googleResult = {
        :content_type => '',
        :google_id => '',
        :google_contents => '',
        :name => '',
        :google_updated_at => '',
        :is_valid => 'false'
      }
    end
    render json: googleResult
  end

private

  def check_user_permission
    check_permission 'documents'
  end

  def set_document
    @document = Document.find params[:id]
  end

  def document_params
    params.require(:document).permit(:name, :document_updated_on, :content_type, :file, :_destroy, :google_url, :google_id, :google_contents, :google_updated_at, :category_ids, :exclude_from_newest)
  end

end