*** Settings ***
Resource    common.resource
Resource    ../variables/aviationstack_variables.robot

*** Variables ***
${FLIGHTS_ENDPOINT}    /flights
${AIRPORTS_ENDPOINT}   /airports
${AIRLINES_ENDPOINT}   /airlines



*** Keywords ***
Given I have a valid AviationStack session
    Create Session    aviation    ${BASE_URL}

Given I have a valid API key
    [Arguments]    ${api_key}
    Set Test Variable    ${API_KEY}    ${api_key}

Given I have an invalid API key
    Set Test Variable    ${API_KEY}    invalid_key_123

When I perform a GET request to flights endpoint
    [Arguments]    ${query_params}  ${expected_status}
    ${params}=    Set To Dictionary    ${query_params}    access_key=${API_KEY}
    ${response_get}=    GET
    ...    ${BASE_URL}${FLIGHTS_ENDPOINT}
    ...    expected_status=${expected_status}
    ...    verify=${False}
    ...    params=${params}
    Set Test Variable    ${response_get}

Then response status code should be
    [Arguments]    ${expected_status}
    Should Be Equal As Integers    ${response_get.status_code}    ${expected_status}

Then response body should not be empty
    ${json}=    Set Variable    ${response_get.json()}
    ${data}=    Get From Dictionary    ${json}    data
    Should Not Be Empty    ${data}
  
Then response body should be empty
    ${json}=    Set Variable    ${response_get.json()}
    ${data}=    Get From Dictionary    ${json}    data
    Should Be Empty   ${data}



Then response should contain departure iata
    [Arguments]    ${expected_iata}
    ${json}=    Set Variable     ${response_get.json()}
    ${data}=    Get From Dictionary    ${json}    data
    ${first_flight}=    Get From List    ${data}    0
    ${departure}=    Get From Dictionary    ${first_flight}    departure
    ${iata}=    Get From Dictionary    ${departure}    iata
    Should Be Equal As Strings    ${iata}    ${expected_iata}

Then response should contain authentication error
    ${json}=    Set Variable    ${response_get.json()}
    Dictionary Should Contain Key    ${json}    error