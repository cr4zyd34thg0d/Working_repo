{
    "description": "Automation Document Example JSON Template",
    "schemaVersion": "0.3",
    "assumeRole": "{{ AutomationAssumeRole }}",
    "parameters": {
        "AutomationAssumeRole": {
            "type": "String",
            "description": "The ARN of the role"
        },
        "SSMDocumentID": {
            "type": "String",
            "description": "{{ SSMDocumentID }}"
        }
    },
    "mainSteps": [
        {
            "name": "SSMRemediation",
            "action": "aws:executeAwsApi",
            "inputs": {
                "Service": "ssm",
                "Api": "modify-document-permission",
                "Name": "{{SSMDocumentID}}",
                "PermissionType": "Share",
                "AccountIdsToRemove": ["All"]
            }
        }
    ]
}