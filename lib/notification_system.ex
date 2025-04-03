defmodule SmsNotifier do
  @moduledoc """
  A lightweight wrapper for sending SMS messages using the configured Twilio client.

  This module allows you to send SMS messages through Twilio by abstracting the underlying
  client implementation. By default, it uses `ExTwilio.Message`, but this can be overridden
  via application configuration using the `:twilio_client` key.

  ## Configuration

  To override the default SMS client, set the following in your config:

      config :my_app, :twilio_client, MyCustomTwilioClient

  ## Author
  [author]

  ## Version
  [version]

  ## Complexity
  This module has low complexity and acts as a thin wrapper over the Twilio SMS client.

  ## Since
  2025-04-03
  """

  @message_client Application.compile_env(:my_app, :twilio_client, ExTwilio.Message)

  @doc """
  Sends an SMS message using the configured Twilio client.

  ## Parameters

    - `to` (string): The recipient's phone number in E.164 format.
    - `body` (string): The content of the SMS message.

  ## Returns

    - `:ok` if the message is sent successfully.
    - `{:error, reason}` if the message fails to send.

  Internally, this function uses the configured message client module to invoke
  the `create/1` function with the required message parameters.

  ## Examples

      iex> SmsNotifier.send_sms("+1234567890", "Hello, world!")
      :ok

      iex> SmsNotifier.send_sms("+1234567890", "")
      {:error, :invalid_body}

  ## Author
  [author]

  ## Version
  1.0

  ## Complexity
  This function has low complexity, performing a single external API call and basic error handling.

  ## Since
  2025-04-03
  """
  def send_sms(to, body) do
    case @message_client.create(to: to, from: System.get_env("TWILIO_PHONE_NUMBER"), body: body) do
      {:ok, msg} ->
        IO.puts("Message sent: #{msg.sid}")
        :ok

      {:error, reason} ->
        IO.puts("Failed to send SMS: #{inspect(reason)}")
        {:error, reason}
    end
  end
end
