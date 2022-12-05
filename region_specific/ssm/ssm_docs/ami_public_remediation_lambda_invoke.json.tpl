{
  "description": "Automation Document Example JSON Template",  
  "schemaVersion": "0.3",  
  "assumeRole": "{{ AutomationAssumeRole }}",  
  "parameters": {  
    "AutomationAssumeRole": {  
      "type": "String",  
      "description": "The ARN of the role",  
      "default": ""  
    },
    "AccountID": {  
      "type": "String",  
      "description": "{{ AccountID }}"
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
        "FunctionName": "${AMIPublicRemediationLambda}",  
        "Payload": "{\"parameterName\":\"AccountID\",\"parameterValue\":\"{{AccountID}}\"}"
      }  
    }
  ]  
}