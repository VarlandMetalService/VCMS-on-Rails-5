require 'rest-client'

class Document < ApplicationRecord

  before_save :set_doc_update
  after_destroy :update_all_positions

  default_scope { where 'is_valid IS TRUE' }
  default_scope { order(document_updated_on: :desc) }

  self.per_page = 100

  # CarrierWave uploader support
  mount_uploader    :file,
                    FileUploader

  has_and_belongs_to_many   :categories
  belongs_to                :user,
                            foreign_key: 'added_by'

  accepts_nested_attributes_for   :categories,
                                  reject_if: :all_blank,
                                  allow_destroy: false

  validates :name,
            presence: true
  validates :user,
            presence: true
  validates :content_type,
            presence: true

  scope :search_query, ->(query) {
    return if query.blank?
    cond_text = Array.new
    cond_values = Array.new
    query.split(/\s(?=(?:[^'"]|'[^']*'|"[^"]*")*$)/).select {|s| not s.empty? }.map {|s| s.gsub(/(^ +)|( +$)|(^["']+)|(["']+$)/,'')}.each{|w|
      cond_text << "(documents.name like ? or google_contents like ?)"
      cond_values << "%#{w}%" << "%#{w}%"
    }
    where cond_text.join(' AND '), *cond_values
  }
  scope :with_date_gte, lambda { |reference_time|
    where 'document_updated_on >= ?', reference_time.to_date
  }
  scope :with_date_lte, lambda { |reference_time|
    where 'document_updated_on < ?', reference_time.to_date + 1
  }
  scope :not_excluded, ->() {
    where 'exclude_from_newest IS FALSE'
  }

  def self.options_for_sorted_by
    [
      ['Date (newest first)', 'document_updated_on DESC'],
      ['Date (oldest first)', 'document_updated_on']
    ]
  end

  def lookup_google_info
    return if self.google_url.nil?
    begin
      response = RestClient.get 'https://script.google.com/macros/s/AKfycbxXLu_t6lEyYUpLQ3s5tcfQz-691nGEuOV-eK7tce5uTmcbToM/exec', params: { url: self.google_url }, accept: :json
      parsed = JSON.parse(response)
      if parsed['valid']
        self.content_type = "google/#{parsed['type']}"
        self.google_id = parsed['id']
        self.google_contents = parsed['contents']
        self.name = parsed['title']
        self.google_updated_at = Time.new
        self.is_valid = true
      else
        self.is_valid = false
      end
    rescue => e
      logger.debug "ERROR (Document Model - lookup_google_info): #{e.message}"
      self.is_valid = false
    end
  end

  def update_google_info
    return if self.google_url.nil?
    type_pre = self.content_type
    id_pre = self.google_id
    contents_pre = self.google_contents
    name_pre = self.name
    self.lookup_google_info
    unless self.content_type == type_pre && self.google_id == id_pre && self.google_contents == contents_pre && self.name == name_pre
      self.document_updated_on = Date.today
    end
    self.save!
  end

private

  def set_doc_update
    if self.document_updated_on.nil?
      self.document_updated_on = Date.today
    end
  end

  def update_all_positions
    Category.update_positions
  end

end
