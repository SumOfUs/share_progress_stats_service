class HealthCheckController < ActionController::API

  def haiku
    render plain: health_check_haiku, status: 200
  end

  private

  def health_check_haiku
    "Health check is passing,\n"\
    "don't terminate the instance.\n"\
    "Response: 200."
  end
end

