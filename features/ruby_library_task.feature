Feature: PaperHouse::RubyLibraryTask
  Scenario: Simple C extension
    Given the current project directory is "examples/ruby_extension"
    When I run rake "hello"
    Then I successfully run `ruby -I. -rhello -e "p Hello"`
    And the output should contain:
    """
    Hello
    """

  Scenario: Build simple C extension with specifying 'CC=' option
    Given the current project directory is "examples/ruby_extension"
    When I run rake "hello CC=/usr/bin/llvm-gcc"
    Then I successfully run `ruby -I. -rhello -e "p Hello"`
    And the output should contain:
    """
    Hello
    """
