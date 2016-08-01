require 'rails_helper'
require './lib/share_analytics_updater'

describe ShareAnalyticsUpdater::EnqueueJobs do
  let(:page)    { Page.create(title: 'Foo', slug: 'foo', publish_status: 0)}
  let!(:button) { Share::Button.create(page: page, url: 'foo.com') }

  let(:sqs_client) { double }

  before do
    allow(Aws::SQS::Client).to receive(:new){ sqs_client }
    allow(ENV).to receive(:[]).with("SQS_QUEUE_URL"){'bar.com'}
  end

  subject { described_class }

  it 'enqueues' do
    expected_arguments = {
      queue_url: 'bar.com',
      delay_seconds: 2,
      message_body: {
        type: 'update_share',
        button_id: button.id
      }.to_json
    }

    expect(sqs_client).to receive(:send_message).with(expected_arguments)
    subject.run
  end
end

describe ShareAnalyticsUpdater::FetchAnalytics do
  let(:button) { Share::Button.create(page_id: '1', url: 'foo.com', sp_id: '159400') }

  context 'for existing buttons' do
    subject do
      VCR.use_cassette('share_button_fetch_analytics_success') do
        ShareAnalyticsUpdater.update_share(button.id)
      end
    end

    it 'updates button with stats' do
      subject
      data = JSON.parse(button.reload.analytics)['response']

      expect(data.first).to include({'id' => 159400})
      expect(data.first.keys).to match_array(%w{created_at id share_types generations share_tests total})
    end
  end

  context 'for non-existing buttons' do
    let(:button) { Share::Button.create(page_id: '1', url: 'foo.com', sp_id: 'xyzBaD') }

    subject do
      VCR.use_cassette('share button fetch analytics failure') do
        ShareAnalyticsUpdater.update_share(button.id)
      end
    end

    xit 'raises ShareProgressApiError' do
      expect{
        subject
      }.to raise_error(ShareProgressApiError, /ShareProgress web server responded with status 404 Not Found/)
    end
  end

  context 'for nil ID buttons' do
    let(:button) { Share::Button.create(page_id: '1', url: 'foo.com', sp_id: nil) }

    subject do
      VCR.use_cassette('share button fetch analytics failure nil id') do
        ShareAnalyticsUpdater.update_share(button.id)
      end
    end

    xit 'raises ShareProgressApiError' do
      expect{
        subject
      }.to raise_error(ShareProgressApiError, /ShareProgress web server responded with status 404 Not Found/)
    end
  end
end

