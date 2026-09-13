defmodule Alloy.Money do
  @doc """
  Formats an integer amount in cents as a dollar string.

  ## Examples

      iex> Alloy.Money.format(150000)
      "$1,500.00"

      iex> Alloy.Money.format(92)
      "$0.92"

  """
  def format(cents) when is_integer(cents) do
    dollars = abs(cents) |> div(100)
    remaining_cents = abs(cents) |> rem(100)

    formatted = "$#{add_commas(dollars)}.#{pad(remaining_cents)}"

    if cents < 0 do
      "(#{formatted})"
    else
      formatted
    end
  end

  defp pad(cents) do
    Integer.to_string(cents) |> String.pad_leading(2, "0")
  end

  defp add_commas(number) do
    number
    |> Integer.to_string()
    |> String.reverse()
    |> String.replace(~r/(\d{3})(?=\d)/, "\\1,")
    |> String.reverse()
  end

  def parse(""), do: 0

  def parse(dollar_string) when is_binary(dollar_string) do
    case String.split(dollar_string, ".") do
      [dollars] ->
        String.replace(dollars, ",", "") |> String.to_integer() |> then(&(&1 * 100))

      [dollars, cents] ->
        dollars_in_cents =
          String.replace(dollars, ",", "")
          |> String.to_integer()
          |> then(&(&1 * 100))

        cents_integer = String.pad_trailing(cents, 2, "0") |> String.to_integer()

        dollars_in_cents + cents_integer
    end
  end
end
