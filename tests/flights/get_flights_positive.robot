*** Settings ***
Resource    ../../resources/aviationstack_keywords.resource

*** Test Cases ***
Get active flights from GRU
    Given I have a valid AviationStack session
    Given I have a valid API key    cfd77ccd4625cab36017fd91699579a1
    When I perform a GET request to flights endpoint
    ...    {"limit": 10, "flight_status": "active", "dep_iata": "GRU"}
    ...    200
    Then response status code should be    200
    Then response body should not be empty
    Then response should contain departure iata    GRU

Get flights with invalid API key
    Given I have a valid AviationStack session
    Given I have an invalid API key
    When I perform a GET request to flights endpoint
    ...    {"limit": 5}
    ...    401
    Then response status code should be    401
    Then response should contain authentication error

Get flights with invalid place
     Given I have a valid AviationStack session
    Given I have a valid API key    cfd77ccd4625cab36017fd91699579a1
    When I perform a GET request to flights endpoint
    ...    {"limit": 10, "flight_status": "active", "dep_iata": "INVALID"}
    ...    200
    Then response status code should be    200
    Then response body should be empty

Error to get flights by date
     Given I have a valid AviationStack session
    Given I have a valid API key    cfd77ccd4625cab36017fd91699579a1
    When I perform a GET request to flights endpoint
    ...    {"limit": 10, "flight_status": "active", "dep_iata": "GRU", "flight_date": "2026-01-15"}
    ...    403
    Then response should contain authentication error

Error to get flights by date fail test
    Given I have a valid AviationStack session
    Given I have a valid API key    cfd77ccd4625cab36017fd91699579a1
    When I perform a GET request to flights endpoint
    ...    {"limit": 10, "flight_status": "active", "dep_iata": "GRU", "flight_date": "2026-01-15"}
    ...    200
    Then response should contain authentication error

Scenario: Get airports by valid IATA code
    Given I have a valid AviationStack session
    Given I have a valid API key    cfd77ccd4625cab36017fd91699579a1
    When I perform a GET request to airlines endpoint with params
    ...     {"limit": 10, "iata": "GRU"}
    ...        expected_status=200
    Then response body should not be empty
    And response should contain pagination
    And each airline should have mandatory fields


Scenario: Get airports by country=BR
    Given I have a valid AviationStack session
    Given I have a valid API key    cfd77ccd4625cab36017fd91699579a1
    When I perform a GET request to airports endpoint with params
    ...  {"country_name": "Brazil"}                
    ...  expected_status=200
    Then Then response body should not be empty
    And response should contain country    Brazil

Scenario: Get airports by country=USA
    Given I have a valid AviationStack session
    Given I have a valid API key    cfd77ccd4625cab36017fd91699579a1
    When I perform a GET request to airports endpoint with params
    ...  {"country_name": "UNITED STATES"}                
    ...  expected_status=200
    Then Then response body should not be empty
    And response should contain country    United States


Scenario: Get airports by country=France
    Given I have a valid AviationStack session
    Given I have a valid API key    cfd77ccd4625cab36017fd91699579a1
    When I perform a GET request to airports endpoint with params
    ...  {"country_name": "FRANCE"}                
    ...  expected_status=200
    Then Then response body should not be empty
    And response should contain country    France
