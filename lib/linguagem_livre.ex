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
    #IO.inspect(p)

    # limpar entrada
    %{non_terminal: n1, terminal: t1, production: p1} = clear_rules(n, t, p, s)
    #IO.inspect(n1)
    #IO.inspect(t1)
    #IO.inspect(p1)

    # criar simbolos não terminais que vão pra terminais
    %{new_symbols: n2, new_rules: p2} = create_new_non_terminal_rules(n1, t1)
    #IO.inspect(p2)

    # substituir
    p3 = substitute(t1, p1, p2)
    #IO.inspect(p3)

    # criar símbolos intermediários
    %{new_symbols: n3, new_rules: p4} = create_intermidiate_rules_loop(n1 ++ n2, t1, p3, '')
    #IO.inspect(p4)

    # limpeza final
    %{non_terminal: n4, terminal: t2, production: p5} = clear_rules(n1 ++ n2 ++ n3, t1, p4, s)

    # gramática final
    %LinguagemLivre{
      non_terminal: Enum.sort(n4),
      terminal: Enum.sort(t2),
      production: p5,
      start: s
    } #|> IO.inspect
  end

  def clear_rules(n, t, p, s) do
    # eliminar regras de produção de epsilon
    p1 = delete_E_symbols_loop(p)
    #IO.inspect(p1)
    # eliminar símbolos únicos
    p2 = delete_unit_symbols_loop(n, p1)
    #IO.inspect(p2)
    # eliminar símbolos inalcansáveis
    p3 = delete_unreachable_loop(n, t, p2, s)
    #IO.inspect(p3)
    # limpar símbolos não mais utilizados
    %{
      non_terminal: Enum.filter(n, fn(symbol) ->
        Enum.any?(p3, &(symbol == &1.alpha))
      end),
      terminal: Enum.filter(t, fn(symbol) ->
        Enum.any?(p3, &(symbol in &1.beta))
      end),
      production: p3
    }
  end

  def delete_E_symbols_loop(p) do
    e_rules = Enum.filter(p, fn (rule) ->
      rule.beta == ''
    end)
    if (length(e_rules) == 0) do
      p
    else
      new_rule_list = Enum.reduce(e_rules , p, fn(e_rule, rules_so_far) ->
        Enum.filter(rules_so_far, fn (rule) ->
          e_rule.alpha in rule.beta
        end) |>
        Enum.map(fn(rule) ->
          %{
            alpha: rule.alpha,
            beta: Enum.reject(rule.beta, &(&1 == e_rule.alpha))
          }
        end) |>
        MapSet.new |>
        MapSet.union(rules_so_far) |>
        MapSet.delete(e_rule)
      end)
      delete_E_symbols_loop(new_rule_list)
    end
  end

  def delete_unit_symbols_loop(n, p) do
    unit_rules = Enum.filter(p, fn(rule) ->
      length(rule.beta) == 1 and List.first(rule.beta) in n
    end)
    if (length(unit_rules) == 0) do
      p
    else
      new_rule_list = Enum.reduce(unit_rules, p, fn(unit_rule, rules_so_far) ->
        Enum.filter(rules_so_far, fn(rule) ->
          unit_rule.beta == [rule.alpha]
        end) |>
        Enum.map(fn(rule) ->
          %{
            alpha: unit_rule.alpha,
            beta: rule.beta
          }
        end) |>
        Enum.reject(fn(rule) ->
          [rule.alpha] == rule.beta
        end) |>
        MapSet.new |>
        MapSet.union(rules_so_far) |>
        MapSet.delete(unit_rule)
      end)
      delete_unit_symbols_loop(n, new_rule_list)
    end
  end

  def delete_unreachable_loop(n, t, p, s) do
    usefuls = get_usefuls_loop(p, MapSet.new(t))
    p1 = Enum.filter(p, fn (rule) ->
      rule.alpha in usefuls and Enum.any?(rule.beta, &(&1 in usefuls))
    end)
    p2 = Enum.filter(p1, fn(rule) ->
      rule.alpha == s or Enum.any?(p1, &(rule.alpha in &1.beta))
    end) |>
    MapSet.new
    if (MapSet.equal?(p, p2)) do
      p
    else
      delete_unreachable_loop(n, t, p2, s)
    end
  end

  def get_usefuls_loop(p, result) do
    useful_alphas = Enum.filter(p, fn(rule) ->
      Enum.all?(rule.beta, &(&1 in result))
    end) |>
    Enum.map(fn (rule) ->
      rule.alpha
    end) |>
    MapSet.new
    if (MapSet.subset?(useful_alphas, result)) do
      result
    else
      get_usefuls_loop(p, MapSet.union(useful_alphas, result))
    end
  end

  def create_intermidiate_rules_loop(n, t, p, new_symbols) do
    if Enum.any?(p, fn(rule) -> length(rule.beta) > 2 end) do
      %{new_symbols: ns, new_rules: np} = create_intermidiate_rules(n ++ t ++ new_symbols, p)
      # substituir
      pf = substitute(t, p, np)
      create_intermidiate_rules_loop(n, t, pf, ns ++ new_symbols)
    else
      %{new_symbols: new_symbols, new_rules: p}
    end
  end

  def create_new_non_terminal_rules(n, t) do
    Enum.reduce(t, %{new_symbols: [], new_rules: MapSet.new()}, fn (symbol, %{new_symbols: ns, new_rules: nr}) ->
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
    end) |>
    Enum.reduce(%{new_symbols: [], new_rules: MapSet.new()}, fn(rule, acc) ->
      if (Enum.any?(MapSet.union(p, acc.new_rules), &(&1.beta == Enum.take(rule.beta, -2)))) do
        acc
      else
        symbol = find_available_symbol(?A, acc.new_symbols ++ v)
        %{
          new_symbols: [symbol | acc.new_symbols],
          new_rules: MapSet.put(acc.new_rules, %{
            alpha: symbol,
            beta: Enum.take(rule.beta, -2)
            })
          }
      end
    end)
  end

  def find_available_symbol(symbol_to_try, v) do
    if(symbol_to_try not in v, do: symbol_to_try, else: find_available_symbol(symbol_to_try+1, v))
  end

  def substitute(t, old_rules, new_rules) do
    not_to_change = Enum.filter(old_rules, fn (rule) ->
      length(rule.beta) == 1 and List.first(rule.beta) in t
    end) |> MapSet.new
    Enum.map(MapSet.difference(old_rules, not_to_change), fn %{alpha: alpha, beta: beta} ->
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
    end) |> MapSet.new |> MapSet.union(new_rules) |> MapSet.union(not_to_change)
  end

  @spec belongs_to_grammar(charlist, LinguagemLivre.t) :: boolean
  def belongs_to_grammar(word, grammar) do
    normalized = normalize(grammar)
    memory = calculate_word(word, normalized, %{})
    Map.get(memory, word, []) |> Enum.any?(&(&1 == normalized.start))
  end

  def calculate_word(word, l = %{production: p}, memory) do
    if Map.has_key?(memory, word) do # word was already calculated
      memory
    else
      if length(word) > 1 do

        prefix_suffix = 1..(length(word) - 1) |>
        Enum.map(&(Enum.split(word, &1)))

        new_memory = Enum.reduce(prefix_suffix, memory, fn ({prefix, suffix}, partial_memory) ->
          partial_memory1 = calculate_word(prefix, l, partial_memory)
          calculate_word(suffix, l, partial_memory1)
        end)

        possible_alphas = prefix_suffix |>
        Enum.map(fn ({prefix, suffix}) ->
          {Map.get(new_memory, prefix), Map.get(new_memory, suffix)}
        end) |>
        Enum.filter(fn ({preList, sufList}) ->
          length(preList) > 0 and length(sufList) > 0
        end) |>
        Enum.map(fn ({preList, sufList}) ->
          Enum.map(preList, fn (symbol) ->
            Enum.map(sufList, &([symbol, &1]))
          end)
        end) |>
        Enum.map(fn (possible_beta_list_list) ->
          Enum.map(possible_beta_list_list, fn (possible_beta_list) ->
            Enum.map(possible_beta_list, fn (possible_beta) ->
              Enum.filter(p, &(&1.beta == possible_beta)) |> Enum.map(&(&1.alpha))
            end)
          end)
        end) |>
        List.flatten |>
        Enum.uniq

        Map.put(new_memory, word, possible_alphas)
      else
        Map.put(memory, word, Enum.filter(p, &(&1.beta == word)) |> Enum.map(&(&1.alpha)))
      end
    end
  end

end
