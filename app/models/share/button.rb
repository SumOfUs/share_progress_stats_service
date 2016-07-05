class Share::Button < ActiveRecord::Base
  belongs_to :page
  scope :with_page, -> { includes(:pages) }
  scope :where_page_is_active, -> { where(pages: {active: true}) }


  def self.ids_of_active_buttons
      includes(:page).
        order("share_buttons.updated_at asc").
        where_page_is_active.
        limit(15).ids
  end
end
