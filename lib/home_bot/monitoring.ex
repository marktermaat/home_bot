defmodule HomeBot.Monitoring do
  @moduledoc "All tasks for monitoring"

  alias HomeBot.Monitoring.MonitoringJob

  def run_monitoring_job do
    MonitoringJob.run()
  end
end
