defmodule LinguagemLivreTest do
  use ExUnit.Case
  doctest LinguagemLivre

  test "normalize" do
    non_terminal = [?E, ?F, ?T]
    terminal = [?(, ?), ?*, ?+, ?i]
    production = MapSet.new([
      %{
        alpha: ?E,
        beta: [?E, ?+, ?T]
      },
      %{
        alpha: ?E,
        beta: [?T]
      },
      %{
        alpha: ?T,
        beta: [?T, ?*, ?F]
      },
      %{
        alpha: ?T,
        beta: [?F]
      },
      %{
        alpha: ?F,
        beta: [?(, ?E, ?)]
      },
      %{
        alpha: ?F,
        beta: [?i]
      }
    ])
    start = ?E
    grammar = %LinguagemLivre{
      non_terminal: non_terminal,
      terminal: terminal,
      production: production,
      start: start
    }
    test0_non_terminal = [
      ?A, ?B, ?C, ?D, ?E, ?F, ?G, ?H, ?I, ?T
    ]
    test0_production = MapSet.new([
      %{alpha: ?A, beta: [?(] },
      %{alpha: ?B, beta: [?)] },
      %{alpha: ?C, beta: [?*] },
      %{alpha: ?D, beta: [?+] },
      %{alpha: ?E, beta: [?E, ?G] },
      %{alpha: ?E, beta: [?E, ?H] },
      %{alpha: ?G, beta: [?C, ?T] },
      %{alpha: ?H, beta: [?D, ?E] },
      %{alpha: ?I, beta: [?E, ?B] },
      %{alpha: ?T, beta: [?A, ?I] },
      %{alpha: ?T, beta: [?i] }
    ])
    test0 = %LinguagemLivre{
      non_terminal: test0_non_terminal,
      terminal: terminal,
      production: test0_production,
      start: start
    }
    assert LinguagemLivre.normalize(grammar) == test0

  end
end
