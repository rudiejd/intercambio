defmodule Intercambio.Translate do
  @moduledoc """
  Translate from a given language to another by calling a LibreTranslate server
  """
  require Logger

  @translate_url "http://localhost:7500/translate"

  @spec translate(text :: String.t(), from_language :: String.t(), to_language :: String.t()) ::
          {:ok, String.t()} | {:error, Exception.t()}
  def translate(text, from_language, to_language) do
    build_request(text, from_language, to_language)
    |> Req.post()
    |> handle_response()
  end

  defp handle_response({:ok, %Req.Response{status: 200, body: body}}) do
    {:ok, translation} = Jason.decode(body)
    case Map.get(translation, "translatedText") do
      nil -> {:error, "No translated text in LibreTranslate response"}
      text -> {:ok, text}
    end
  end

  defp handle_response({:error, error}) do
    {:error, error}
  end

  defp handle_response({_, %Req.Response{status: status, body: body}}) do
    Logger.error("Received unknown response with status #{status} from LibreTranslate: #{IO.inspect(body)}")
    {:error, "Unknown response received"}
  end

  defp build_request(text, from_language, to_language) do
    {:ok, body} =
      %{
        "q" => text,
        "source" => from_language,
        "target" => to_language,
        "format" => "text",
        "alternatives" => 1,
        "api_key" => ""
      }
      |> Jason.encode()

    Req.Request.new(
      method: :post,
      url: @translate_url,
      body: body,
      headers: %{"Content-Type" => "application/json"}
    )
  end
end
