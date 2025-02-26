defmodule AllowIframe do
  @moduledoc """
  Allows affected ressources to be open in iframe.
  """
  alias Plug.Conn

  def init(opts \\ %{}), do: Map.new(opts)

  def call(conn, _opts) do
    Conn.put_resp_header(conn, "x-frame-options", "ALLOW-FROM " <> "http://localhost:3030")
  end
end
