defmodule LinguagemLivreTest do
  use ExUnit.Case
  doctest LinguagemLivre

  test "normalize" do
    non_terminal = [?E, ?T, ?F]
    terminal = [?(, ?), ?i, ?+, ?*]
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
      ?I, ?H, ?G, ?E, ?T, ?F, ?D, ?C, ?B, ?A
    ]
    test0_production = MapSet.new([
      %{alpha: ?C, beta: [?+] },
      %{alpha: ?D, beta: [?*] },
      %{alpha: ?A, beta: [?(] },
      %{alpha: ?B, beta: [?)] },
      %{alpha: ?T, beta: [?i] },
      %{alpha: ?E, beta: [?E, ?G] },
      %{alpha: ?E, beta: [?E, ?H] },
      %{alpha: ?G, beta: [?C, ?E] },
      %{alpha: ?H, beta: [?D, ?T] },
      %{alpha: ?I, beta: [?E, ?B] },
      %{alpha: ?T, beta: [?A, ?I] }
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
