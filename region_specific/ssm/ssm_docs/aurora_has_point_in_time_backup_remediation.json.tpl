{
    "description": "Automation Document Example JSON Template",
    "schemaVersion": "0.3",
    "assumeRole": "{{ AutomationAssumeRole }}",
    "parameters": {
        "AutomationAssumeRole": {
            "type": "String",
            "description": "The ARN of the role"
        },
        "DatabaseID": {
            "type": "String",
            "description": "{{ DatabaseID }}"
        }
    },
    "mainSteps": [
        {  
        "name": "invokeMyLambdaFunction",  
        "action": "aws:invokeLambdaFunction",  
        "maxAttempts": 3,  
        "timeoutSeconds": 120,  
        "onFailure": "Abort",  
        "inputs": {  
            "FunctionName": "${AuroraRecoveryPointRemediationLambda}",  
            "Payload": "{\"parameterName\":\"DatabaseID\", \"parameterValue\":\"{{DatabaseID}}\"}" 
        }
        }
    ]
}
