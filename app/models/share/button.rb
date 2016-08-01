class Share::Button < ActiveRecord::Base
  belongs_to :page
  scope :with_page, -> { includes(:pages) }
  scope :where_page_is_published, -> { where(pages: {publish_status: 0}) }


  def self.ids_of_active_buttons
      includes(:page).
        order("share_buttons.updated_at asc").
        where_page_is_published.
        limit(15).ids
  end
end
