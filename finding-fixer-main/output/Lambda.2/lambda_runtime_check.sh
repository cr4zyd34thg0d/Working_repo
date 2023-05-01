#!/bin/bash
# filename: lambda_runtime_check.sh
# Finding: Lambda.2 Lambda functions should use supported runtimes

aws lambda list-functions --query "Functions[*].[FunctionName, Runtime]" --output text | awk '{if($2 != "nodejs" && $2 != "python2.7" && $2 != "python3.6" && $2 != "java8" && $2 != "dotnetcore1.0" && $2 != "dotnetcore2.0") print $0}' | cut -f1 > unsupported_runtimes.txt