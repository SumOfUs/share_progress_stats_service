require 'rails_helper'

describe Share::Button do
  describe '.ids_of_active_buttons' do
    let(:active_page) { Page.create(title: 'foo',   slug: 'slug', active: true) }
    let(:inactive_page) { Page.create(title: 'foo', slug: 'slug', active: false) }

    subject { Share::Button.ids_of_active_buttons }

    before do
      Timecop.freeze do
        @active_page_buttons = 3.times.inject([]) do |memo, i|
          Timecop.travel(1.day + i.hours) do
            memo << Share::Button.create(page: active_page)
          end
        end
      end

      3.times.inject([]) do |memo, i|
        memo << Share::Button.create(page: inactive_page)
      end
    end

    it 'returns buttons ordered by updated_at for active pages' do
      expect( subject ).to eq(
        @active_page_buttons.map(&:id)
      )
    end
  end
end
