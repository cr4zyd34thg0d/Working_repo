{
    "description": "Automation Document Example JSON Template",
    "schemaVersion": "0.3",
    "assumeRole": "{{ AutomationAssumeRole }}",
  "parameters": {  
    "NetworkAclID": {  
      "type": "String",  
      "description": "{{ NetworkAclID }}"  
    },  
    "AutomationAssumeRole": {
      "type": "String",
      "description": "The ARN of the role"
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
        "FunctionName": "${NACLSUnrestrictedRemediationLambda}",  
        "Payload": "{\"parameterName\":\"NetworkAclID\", \"parameterValue\":\"{{NetworkAclID}}\"}"  
      }  
    }
  ]  
}