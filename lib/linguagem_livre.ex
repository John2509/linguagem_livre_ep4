defmodule LinguagemLivre do

  @type t :: %LinguagemLivre{
    non_terminal: list(char),
    terminal: list(char),
    production: MapSet.t(%{
      alpha: char,
      beta: charlist()
    }),
    start: char
  }
  defstruct [non_terminal: [], terminal: [], production: MapSet.new(), start: ?\0]

  @spec normalize(LinguagemLivre.t) :: LinguagemLivre.t
  def normalize(%{non_terminal: n, terminal: t, production: p, start: s}) do
    # eliminar símbolos únicos
    p1 = delete_unit_symbols(n, p)

    # criar simbolos não terminais que vão pra terminais
    %{new_symbols: nn, new_rules: p2} = create_new_non_terminal_rules(n, t, p1)

    # substituir
    p3 = substitute(p1, p2)

    # criar símbolos intermediários
    %{new_symbols: nin, new_rules: p4} = create_intermidiate_rules(n ++ nn ++ t, p3)

    # substituir
    p5 = substitute(p3, p4)

    # gramática final
    %LinguagemLivre{
      non_terminal: Enum.sort(n ++ nn ++ nin),
      terminal: Enum.sort(t),
      production: p5,
      start: s
    }
  end

  def delete_unit_symbols(n, p) do
    unit_production = Enum.filter(p, fn(rule) ->
      Enum.member?(n, rule.alpha) and length(rule.beta) == 1 and Enum.member?(n, List.first(rule.beta))
    end) |> MapSet.new
    if not (MapSet.size(unit_production) == 0) do
      betas = Enum.map(unit_production, fn(rule) ->
        List.first(rule.beta)
      end)

      Enum.filter(p, fn(rule) ->
        not Enum.member?(unit_production, rule)
      end) |>
      Enum.map(fn(rule) ->
        new_alpha = if Enum.member?(betas, rule.alpha) do
          unit_rule = Enum.find(unit_production, nil, fn(unit) ->
            List.first(unit.beta) == rule.alpha
          end)
          unit_rule.alpha
        else
          rule.alpha
        end
        new_beta = if length(rule.beta) > length(rule.beta -- betas) do
          Enum.reduce(rule.beta, rule.beta, fn(char, acc) ->
            unit_rule = Enum.find(unit_production, %{alpha: rule.alpha, beta: [rule.alpha]}, fn(unit) ->
              List.first(unit.beta) == char
            end)
            String.to_charlist(String.replace(List.to_string(acc), List.to_string(unit_rule.beta), List.to_string([unit_rule.alpha])))
          end)
        else
          rule.beta
        end
        %{
          alpha: new_alpha,
          beta: new_beta
        }
      end) |> MapSet.new
    else
      p
    end
  end

  def create_new_non_terminal_rules(n, t, p) do
    terminal_without_rule = Enum.filter(t, fn symbol ->
      not Enum.any?(p, fn rule ->
        length(rule.beta) == 1 and List.first(rule.beta) == symbol
      end)
    end)
    Enum.reduce(terminal_without_rule, %{new_symbols: [], new_rules: MapSet.new()}, fn (symbol, %{new_symbols: ns, new_rules: nr}) ->
      new_non_terminal = find_available_symbol(?A, n ++ t ++ ns)
      %{
        new_symbols: [new_non_terminal | ns],
        new_rules: MapSet.put(nr, %{
          alpha: new_non_terminal,
          beta: [symbol]
        })
      }
    end)
  end

  def create_intermidiate_rules(v, p) do
    Enum.filter(p, fn(rule) ->
      length(rule.beta) > 2
    end)
    |> Enum.reduce(%{new_symbols: [], new_rules: MapSet.new()}, fn(rule, acc) ->
      symbol = find_available_symbol(?A, acc.new_symbols ++ v)
      %{
        new_symbols: [symbol | acc.new_symbols],
        new_rules: MapSet.put(acc.new_rules, %{
          alpha: symbol,
          beta: Enum.take(rule.beta, -2)
        })
      }
    end)
  end

  def find_available_symbol(symbol_to_try, v) do
    if(symbol_to_try not in v, do: symbol_to_try, else: find_available_symbol(symbol_to_try+1, v))
  end

  def substitute(old_rules, new_rules) do
    Enum.map(old_rules, fn %{alpha: alpha, beta: beta} ->
      new_beta = Enum.reduce(new_rules, beta, fn (new_rule, partial_beta) ->
        if Enum.all?(new_rule.beta, &(&1 in partial_beta)) do
          String.replace(List.to_string(partial_beta), List.to_string(new_rule.beta), List.to_string([new_rule.alpha])) |> String.to_charlist
        else
          partial_beta
        end
      end)
      %{
        alpha: alpha,
        beta: new_beta
      }
    end) |> MapSet.new |> MapSet.union(new_rules)
  end
end
