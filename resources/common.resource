*** Settings ***
Library    RequestsLibrary
Library    JSONLibrary
Library    Collections
Resource   ../variables/aviationstack_variables.robot


*** Keywords ***
Create Aviationstack Session
    Create Session
    ...    aviation
    ...    ${BASE_URL}
    ...    timeout=${TIMEOUT}
