require "net/http"
require "uri"
require 'aws-sdk'
require_relative 'share_progress_api_error'

class ShareAnalyticsUpdater
  class << self
    def enqueue_jobs
      EnqueueJobs.run
    end

    def update_share(id)
      FetchAnalytics.new(id).fetch_and_update
    end
  end

  class FetchAnalytics
    API_URI = URI.parse('http://run.shareprogress.org/api/v1/buttons/analytics')
    API_KEY = ENV['SHARE_PROGRESS_API_KEY']

    def initialize(id)
      @id = id
    end

    def fetch_and_update
      if button.nil?
        Rails.logger.debug("Record Missing - Skipping analytics fetch for Share::Button##{@id}")
        return
      end

      begin
        response = Net::HTTP.post_form(API_URI, { key: API_KEY, id: button.sp_id })
        response_status = response.to_hash["status"].first

        Rails.logger.debug("Fecthing for #{button.sp_id}: #{response_status}")

        if response_status != "200 OK"
           raise ::ShareProgressApiError, "ShareProgress web server responded with status #{response_status}."
        end
        body = JSON.parse(response.body)

        Rails.logger.debug("Fecthed for #{button.sp_id}: #{body['success']}")

        if body['success']
          updated = button.update(analytics: body.to_json )
          Rails.logger.debug("Updating record for #{button.sp_id}: #{updated}")
        else
          raise ::ShareProgressApiError, "ShareProgress isn't happy. It says '#{body['message']}'. \n\n We gave it this: Share::Button - #{button.inspect}"
        end
      rescue => e
        raise ::ShareProgressApiError, e.message
      end
    end

    def button
      @button ||= Share::Button.find(@id)
    end
  end

  class EnqueueJobs
    def self.enqueue(button_id, delay = 1)
      Aws::SQS::Client.new.send_message({
        queue_url:    ENV['SQS_QUEUE_URL'],
        delay_seconds: delay,
        message_body: {
          type:      'update_share',
          button_id: button_id
        }.to_json
      })
    end

    def self.run
      Share::Button.ids_of_active_buttons.each_with_index do |button_id, index|
        delay_in_seconds =  (index + 1) * 2
        enqueue(button_id, delay_in_seconds)
      end
    end
  end
end

