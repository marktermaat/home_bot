defmodule HomeBot.Monitoring do
  @moduledoc "All tasks for monitoring"

  alias HomeBot.Monitoring.MonitoringJob
  alias HomeBot.Monitoring.DailyEnergyMonitoring

  def run_monitoring_job do
    MonitoringJob.run()
  end

  def run_daily_energy_monitoring do
    DailyEnergyMonitoring.run()
  end
end
