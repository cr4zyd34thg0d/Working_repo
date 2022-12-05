{
  "description": "Automation Document Example JSON Template",  
  "schemaVersion": "0.3",  
  "assumeRole": "{{ AutomationAssumeRole }}",  
  "parameters": {  
    "CloudWatchLogGroup": {  
      "type": "String",  
      "description": "{{ CloudWatchLogGroup }}"  
    },  
    "AutomationAssumeRole": {  
      "type": "String",  
      "description": "The ARN of the role",  
      "default": ""  
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
        "FunctionName": "${CloudWatchLogGroupRetentionRemediationLambda}",  
        "Payload": "{\"parameterName\":\"CloudWatchLogGroup\", \"parameterValue\":\"{{CloudWatchLogGroup}}\"}"  
      }  
    }
  ]  
}
