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

When I perform a GET request to airports endpoint with params
    [Arguments]    ${query_params}  ${expected_status}
    ${params}=    Set To Dictionary    ${query_params}    access_key=${API_KEY}
    ${response_get}=    GET
    ...    ${BASE_URL}${AIRPORTS_ENDPOINT}
    ...    expected_status=${expected_status}
    ...    verify=${False}
    ...    params=${params}
    Set Test Variable    ${response_get}

When I perform a GET request to airlines endpoint with params
    [Arguments]    ${query_params}  ${expected_status}
    ${params}=    Set To Dictionary    ${query_params}    access_key=${API_KEY}
    ${response_get}=    GET
    ...    ${BASE_URL}${AIRLINES_ENDPOINT}
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
    Log To Console    ${response_get.json()}
  
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


And response should contain country
    [Arguments]    ${expected_country}
    ${json}=       Set Variable    ${response_get.json()}
    
    # Criamos uma lista apenas com os nomes dos países que vieram no JSON
    ${countries}=    Evaluate    [item['country_name'] for item in $json['data']]
    
    # Validamos se o país esperado está nessa lista
    Should Contain    ${countries}    ${expected_country}


And response should contain pagination
    ${json}=    Set Variable    ${response_get.json()}
    Dictionary Should Contain Key    ${json}    pagination
    ${pagination}=    Get From Dictionary    ${json}    pagination

    Should Be True    ${pagination['limit']} > 0
    Should Be True    ${pagination['count']} <= ${pagination['limit']}
    Should Be True    ${pagination['total']} >= ${pagination['count']}
    Should Be True    ${pagination['offset']} >= 0

And each airline should have mandatory fields
    ${json}=    Set Variable    ${response_get.json()}
    ${data}=    Get From Dictionary    ${json}    data

    FOR    ${index}    ${airline}    IN ENUMERATE    @{data}
        # Log para debug: Se falhar, você saberá em qual posição (index) e o que tinha nela
        Log To Console    Validando item ${index}: ${airline}
        
        # Validação de Chaves
        Dictionary Should Contain Key    ${airline}    id
        Dictionary Should Contain Key    ${airline}    fleet_average_age
        Dictionary Should Contain Key    ${airline}    airline_id
        Dictionary Should Contain Key    ${airline}    callsign
        Dictionary Should Contain Key    ${airline}    iata_code
        Dictionary Should Contain Key    ${airline}    icao_code
        Dictionary Should Contain Key    ${airline}    status

        # Validação de Valores (Usando a sintaxe mais moderna ${variavel}[chave])
        Length Should Be    ${airline}[iata_code]    2
        Length Should Be    ${airline}[icao_code]    3
        
    END