require 'rails_helper'

describe HandlerController do
  describe 'POST#handle' do
    let(:queue) { double('queue') }

    before do
      allow(ShareAnalyticsUpdater).to receive(:update_share)
    end

    it 'delegates to ShareAnalyticsUpdater class' do
      expect(ShareAnalyticsUpdater).to receive(:update_share).
        with('123')

      post :handle, params: { button_id: '123' }
    end

    it 'renders nothing' do
      expect(response.body).to eq('')
      post :handle, params: { button_id: '123' }
    end
  end

  describe 'POST#enqueue' do
    before do
      allow(ShareAnalyticsUpdater).to receive(:enqueue_jobs)
    end

    it 'enqueues jobs' do
      expect(ShareAnalyticsUpdater).to receive(:enqueue_jobs)
      post :enqueue
    end

    it 'renders nothing' do
      expect(response.body).to eq('')
      post :enqueue
    end
  end
end


