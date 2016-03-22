require_relative '../../lib/share_analytics_updater'

class HandlerController < ActionController::API
  def handle
    ShareAnalyticsUpdater.update_share(params[:button_id])
    head :ok
  end

  def enqueue
    ShareAnalyticsUpdater.enqueue_jobs
    head :ok
  end
end

