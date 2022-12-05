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
    "InstanceID": {  
      "type": "String",  
      "description": "{{ InstanceID }}"
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
        "FunctionName": "${EC2SystemsManagerManagedRemediationLambda}",  
        "Payload": "{\"parameterName\":\"AMI\", \"parameterValue\":\"{{InstanceID}}\"}" 
      }
    }
  ] 
}