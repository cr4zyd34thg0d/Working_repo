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
    "AMI": {  
      "type": "String",  
      "description": "{{ AMI }}"
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
        "FunctionName": "${AMIApprovedByTagRemediationLambda}",  
        "Payload": "{\"parameterName\":\"AMI\", \"parameterValue\":\"{{AMI}}\"}" 
      }  
    }
  ]  
}