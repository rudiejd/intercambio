defmodule Intercambio.Alert do
  @moduledoc """
  Funcitons for working with the alert feed
  """

  alias Intercambio.Translate
  require Logger

  @languages ["es", "pt", "zh"]
  @translatable_fields ["header_text", "description"]

  def add_translations_to_alerts(alert_feed) do
    alert_feed
    |> Map.fetch!("entity")
    |> Enum.map(&translate_single_alert/1)
  end

  def translate_single_alert(
        %{
          "alert" => alert_body
        } = alert
      ) do
    translated_alert_body =
      for {key, value} <- alert_body, into: %{} do
        if translatable?(key) do
          {key, translate_single_field(value)}
        else
          {key, value}
        end
      end

      %{alert | "alert" => translated_alert_body}
  end

  defp translatable?(field) do
    field in @translatable_fields
  end

  defp translate_single_field(
         %{"translation" => [%{"language" => "en", "text" => english_text} = english_translation]} =
           field
       ) do
    translations = Enum.reduce(@languages, [english_translation], fn language, acc -> 
        case Translate.translate(english_text, "en", language) do
          {:ok, translated_text} -> 
            [make_translation(language, translated_text) | acc]
          {:error, error} ->
            Logger.error("Unable to translate #{english_text} into language #{language} with error #{IO.inspect(error)}")
            acc
        end
      end)
    # put english at the beginning for ease of reference
    |> Enum.reverse()

    %{field | "translation" => translations}
  end

  defp make_translation(language, text) do
    %{"language" => language, "text" => text}
  end
end
