defmodule BittrexClient do
  @moduledoc """
  Documentation for BittrexClient.
  """

  @doc """
  Hello world.

  ## Examples

      iex> BittrexClient.hello
      :world

  """
  def hello do
    :world
  end
end

defmodule BittrexClient.Public do
  use Tesla

  plug Tesla.Middleware.BaseUrl, "https://bittrex.com/api/v1.1/public"
  plug Tesla.Middleware.JSON
  plug Tesla.Middleware.FollowRedirects

  adapter Tesla.Adapter.Hackney

  defp parse_result(response) do
    if Map.get(response.body, "success") do
      Map.get(response.body, "result")
    end
  end

  def markets() do
    get("/getmarkets")
    |> parse_result
  end

  def currencies() do
    get("/getcurrencies")
    |> parse_result
  end

  # market format: BTC-LTC
  def ticker(market) do
    get("/getticker", query: [market: market])
    |> parse_result
  end

  def market_summary() do
    get("/getmarketsummaries")
    |> parse_result
  end

  def market_summary(market) do
    get("/getmarketsummary", query: [market: market])
    |> parse_result
  end

  # type: buy, sell or both
  def order_book(market, type) do
    get("/getorderbook", query: [market: market, type: type])
    |> parse_result
  end

  def order_book(market) do
    order_book(market, "both")
  end

  def market_history(market) do
    get("/getmarkethistory", query: [market: market])
    |> parse_result
  end
end

defmodule BittrexClient.Market do
  # Market
  # TODO
end

defmodule BittrexClient.Account do
  use Tesla

  plug Tesla.Middleware.JSON
  plug Tesla.Middleware.FollowRedirects

  adapter Tesla.Adapter.Hackney

  # TODO: make it a proper Tesla middleware

  defp account_client(path, req_params \\ %{}) do
    base_url = "https://bittrex.com/api/v1.1/account"
    params = Map.merge(req_params, %{"apikey" => System.get_env("BITTREX_API_KEY"), "nonce" => System.system_time(:microsecond)})
    url_with_params = to_string(URI.merge(URI.parse(base_url <> path), "?" <> URI.encode_query(params)))
    sign = Base.encode16(:crypto.hmac(:sha512, System.get_env("BITTREX_API_SECRET"), url_with_params))
    response = get(url_with_params, headers: %{"apisign" => sign})

    if Map.get(response.body, "success") do
      Map.get(response.body, "result")
    else
      nil
    end
  end

  def balance() do
    account_client("/getbalances")
  end

  def balance(currency) do
    account_client("/getbalance", %{"currency" => currency})
  end

  # TODO: getdepositaddress, withdraw, getorder

  def order_history() do
    account_client("/getorderhistory")
  end

  def order_history(market) do
    account_client("/getorderhistory", %{"market" => market})
  end

  def withdrawal_history() do
    account_client("/getwithdrawalhistory")
  end

  def withdrawal_history(currency) do
    account_client("/getwithdrawalhistory", %{"currency" => currency})
  end

  def deposit_history() do
    account_client("/getdeposithistory")
  end

  def deposit_history(currency) do
    account_client("/getdeposithistory", %{"currency" => currency})
  end
end
