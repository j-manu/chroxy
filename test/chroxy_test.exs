defmodule ChroxyTest do
  use ExUnit.Case, async: true
  doctest Chroxy

  def establish_connection do
    ws_url = Chroxy.connection()
    {:ok, page} = ChromeRemoteInterface.PageSession.start_link(ws_url)
    page
  end

  test "connection should return ws:// endpoint" do
    endpoint = Chroxy.connection()
    ws_uri = URI.parse(endpoint)
    assert ws_uri.scheme == "ws"
  end

  test "can control page & register to events" do
    page = try do
      establish_connection()
    rescue
      IO.puts "MATCH ERROR"
      e in MatchError -> establish_connection()
    end

    url = "https://github.com/holsee"
    ChromeRemoteInterface.RPC.Page.enable(page)
    ChromeRemoteInterface.PageSession.subscribe(page, "Page.loadEventFired", self())
    {:ok, _} = ChromeRemoteInterface.RPC.Page.navigate(page, %{url: url})
    assert_receive {:chrome_remote_interface, "Page.loadEventFired", _}, 5_000
  end
end
