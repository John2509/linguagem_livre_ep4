defmodule LinguagemLivreTest do
  use ExUnit.Case
  doctest LinguagemLivre
  #'''
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
      ?A, ?B, ?C, ?D, ?E, ?F, ?H, ?I, ?J, ?T
    ]
    test0_production = MapSet.new([
      %{alpha: ?A, beta: [?(] },
      %{alpha: ?B, beta: [?)] },
      %{alpha: ?C, beta: [?*] },
      %{alpha: ?D, beta: [?+] },
      %{alpha: ?E, beta: [?i] },
      %{alpha: ?F, beta: [?i] },
      %{alpha: ?T, beta: [?i] },
      %{alpha: ?E, beta: [?A, ?H] },
      %{alpha: ?E, beta: [?E, ?I] },
      %{alpha: ?E, beta: [?T, ?J] },
      %{alpha: ?F, beta: [?A, ?H] },
      %{alpha: ?H, beta: [?E, ?B] },
      %{alpha: ?I, beta: [?D, ?T] },
      %{alpha: ?J, beta: [?C, ?F] },
      %{alpha: ?T, beta: [?A, ?H] },
      %{alpha: ?T, beta: [?T, ?J] },
    ])
    test0 = %LinguagemLivre{
      non_terminal: test0_non_terminal,
      terminal: terminal,
      production: test0_production,
      start: start
    }
    assert LinguagemLivre.normalize(grammar) == test0
  end
  #'''
  #'''
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
  #'''
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
  #'''
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
  #'''
  #'''
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
      ?A, ?B, ?C, ?S
    ]
    test0_production = MapSet.new([
      %{alpha: ?A, beta: [?a] },
      %{alpha: ?B, beta: [?a] },
      %{alpha: ?C, beta: [?b] },
      %{alpha: ?A, beta: [?C, ?C] },
      %{alpha: ?S, beta: [?B, ?A] },
    ])
    test0 = %LinguagemLivre{
      non_terminal: test0_non_terminal,
      terminal: terminal,
      production: test0_production,
      start: start
    }
    assert LinguagemLivre.normalize(grammar) == test0
  end
  #'''
  '''
  test "Remove useless production rules" do
    non_terminal = [?S, ?A, ?B, ?C]
    terminal = [?a, ?b]
    production = MapSet.new([
      %{
        alpha: ?S,
        beta: [?a, ?S]
      },
      %{
        alpha: ?S,
        beta: [?A]
      },
      %{
        alpha: ?S,
        beta: [?C]
      },
      %{
        alpha: ?A,
        beta: [?a]
      },
      %{
        alpha: ?B,
        beta: [?a, ?a]
      },
      %{
        alpha: ?C,
        beta: [?a, ?C, ?b]
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
      ?A, ?S
    ]
    test0_terminal = [
      ?a
    ]
    test0_production = MapSet.new([
      %{alpha: ?A, beta: [?a] },
      %{alpha: ?S, beta: [?a] },
      %{alpha: ?S, beta: [?B, ?A] },
      %{alpha: ?S, beta: [?B, ?A] },
    ])
    test0 = %LinguagemLivre{
      non_terminal: test0_non_terminal,
      terminal: test0_terminal,
      production: test0_production,
      start: start
    }
    assert LinguagemLivre.normalize(grammar) == test0
  end
  '''

end
