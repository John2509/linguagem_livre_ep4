defmodule LinguagemLivreTest do
  use ExUnit.Case
  doctest LinguagemLivre
  '''
  test "Normalize" do
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
      %{alpha: ?E, beta: [?i] },
      %{alpha: ?F, beta: [?i] },
      %{alpha: ?T, beta: [?i] },
      %{alpha: ?E, beta: [?A, ?G] },
      %{alpha: ?E, beta: [?E, ?H] },
      %{alpha: ?E, beta: [?T, ?I] },
      %{alpha: ?F, beta: [?A, ?G] },
      %{alpha: ?G, beta: [?E, ?B] },
      %{alpha: ?H, beta: [?D, ?T] },
      %{alpha: ?I, beta: [?C, ?F] },
      %{alpha: ?T, beta: [?A, ?G] },
      %{alpha: ?T, beta: [?T, ?I] },
    ])
    test0 = %LinguagemLivre{
      non_terminal: test0_non_terminal,
      terminal: terminal,
      production: test0_production,
      start: start
    }
    assert LinguagemLivre.normalize(grammar) == test0
  end
  '''
  '''
  test "Check if word belongs" do
    non_terminal = [?S, ?T,]
    terminal = [?(, ?)]
    production = MapSet.new([
      %{
        alpha: ?S,
        beta: [?S, ?S]
      },
      %{
        alpha: ?S,
        beta: [?(, ?T]
      },
      %{
        alpha: ?T,
        beta: [?S, ?)]
      },
      %{
        alpha: ?S,
        beta: [?(, ?)]
      }
    ])
    start = ?S
    grammar = %LinguagemLivre{
      non_terminal: non_terminal,
      terminal: terminal,
      production: production,
      start: start
    }
    assert LinguagemLivre.belongs_to_grammar('(()(()))', grammar) == true
    assert LinguagemLivre.belongs_to_grammar('(()))((())', grammar) == false
  end
  '''
  #'''
  test "Check if word belongs with complex grammar" do
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
    assert LinguagemLivre.belongs_to_grammar('i+(i+i)*i+i', grammar) == true
    assert LinguagemLivre.belongs_to_grammar('i*i*()+i', grammar) == false
  end
  #'''
  '''
  test "Remove E rules" do
    non_terminal = [?S, ?M]
    terminal = [?a, ?b]
    production = MapSet.new([
      %{
        alpha: ?S,
        beta: [?a, ?M, ?b]
      },
      %{
        alpha: ?M,
        beta: [?a, ?M, ?b]
      },
      %{
        alpha: ?M,
        beta: []
      }
    ])
    start = ?S
    grammar = %LinguagemLivre{
      non_terminal: non_terminal,
      terminal: terminal,
      production: production,
      start: start
    }
    test0_non_terminal = [
      ?A, ?B, ?C, ?M, ?S
    ]
    test0_production = MapSet.new([
      %{alpha: ?A, beta: [?a] },
      %{alpha: ?B, beta: [?b] },
      %{alpha: ?C, beta: [?M, ?B] },
      %{alpha: ?M, beta: [?A, ?B] },
      %{alpha: ?M, beta: [?A, ?C] },
      %{alpha: ?S, beta: [?A, ?B] },
      %{alpha: ?S, beta: [?A, ?C] },
    ])
    test0 = %LinguagemLivre{
      non_terminal: test0_non_terminal,
      terminal: terminal,
      production: test0_production,
      start: start
    }
    assert LinguagemLivre.normalize(grammar) == test0
  end
  '''
  '''
  test "Remove unit production rules" do
    non_terminal = [?S, ?A, ?B]
    terminal = [?a, ?b]
    production = MapSet.new([
      %{
        alpha: ?S,
        beta: [?a, ?A]
      },
      %{
        alpha: ?A,
        beta: [?a]
      },
      %{
        alpha: ?A,
        beta: [?B]
      },
      %{
        alpha: ?B,
        beta: [?A]
      },
      %{
        alpha: ?B,
        beta: [?b, ?b]
      }
    ])
    start = ?S
    grammar = %LinguagemLivre{
      non_terminal: non_terminal,
      terminal: terminal,
      production: production,
      start: start
    }
    test0_non_terminal = [
      ?A, ?B, ?C, ?M, ?S
    ]
    test0_production = MapSet.new([
      %{alpha: ?A, beta: [?a] },
      %{alpha: ?B, beta: [?b] },
      %{alpha: ?C, beta: [?M, ?B] },
      %{alpha: ?M, beta: [?A, ?B] },
      %{alpha: ?M, beta: [?A, ?C] },
      %{alpha: ?S, beta: [?A, ?B] },
      %{alpha: ?S, beta: [?A, ?C] },
    ])
    test0 = %LinguagemLivre{
      non_terminal: test0_non_terminal,
      terminal: terminal,
      production: test0_production,
      start: start
    }
    assert IO.inspect(LinguagemLivre.normalize(grammar)) == test0
  end
  '''

end
