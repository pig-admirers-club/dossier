Feature: Pagination
  I can paginate dossier repositories

  Scenario: Paginate repositories
    Given I am logged in
    When I click next page
    Then I see the next page of results