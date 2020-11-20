defmodule HomeBot.Bot.Routes.GoogleMapsApi do
  def get_trip_duration(origin, destination) do
    HTTPoison.start()

    %HTTPoison.Response{status_code: 200, body: body} =
      HTTPoison.get!(
        "https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&origins=#{
          safe(origin)
        }&destinations=#{safe(destination)}&key=#{google_maps_key()}"
      )

    Jason.decode!(body)
    |> Map.get("rows")
    |> List.first()
    |> Map.get("elements")
    |> List.first()
    |> Map.get("duration")
    |> Map.get("value")
  end

  defp safe(str) do
    String.replace(str, " ", "%20")
  end

  defp google_maps_key() do
    Application.fetch_env!(:home_bot, :google_maps_key)
  end
end
