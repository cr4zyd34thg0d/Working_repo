#!/usr/bin/env python3

import openai
import os
import re



# Set OpenAI API key
openai.api_key = os.getenv("OPENAI_API_KEY")

if not openai.api_key:
    raise ValueError("OPENAI_API_KEY environment variable not set")

def ai_generate_text(prompt)->str:
    # Define the parameters for the text generation API call
    # model = "gpt-3.5-turbo"
    model="text-davinci-003"
    params = {
        "prompt": prompt,
        "temperature": 0.7,
        "max_tokens": 500,
    }

    # Call the OpenAI API to generate text
    response = openai.Completion.create(
        engine=model,
        prompt=prompt,
        temperature=params["temperature"],
        max_tokens=params["max_tokens"],
    )
    return(response.choices[0].text.strip())


def ai_generate_actionstatement(prompt)->str:
    return( ai_generate_chat(

"""
You are an expert in security and AWS. 
I will give an English statement, which is a security requirement.  You will rewrite this as a description of what should be.
Only reply with a single sentence.

Examples:
Input:  RDS DB instances should have encryption at-rest enabled
Output: Review all RDS DB instances and turn on encryption at-rest if needed
Input: AWS Config should be enabled
Output: Review AWS Config and turn it on if needed
Input: KMS key rotation should be enabled
Output: Review a KMS keys and enable key rotation if needed
 
"""+ prompt ) )



def ai_generate_code(prompt)->str:
    result= ai_generate_chat(
"""
You are expert AWS admin, experienced in bash writing.
Task: Generate code for a given prompt. Output ONLY code.  Suggest an appropriate filename as a comment inside the script on the 3rd line.
Requirements: AWS CLI
Language: Bash
Context: AWS
Audience: Experienced AWS users
Output: Code only, no instructions
"""+prompt
    ) 
    
    code_re = re.search(r"```(.*?)```", result, re.DOTALL)
    if code_re:
        result = code_re.group(1)
    return(result)
    
    



def ai_generate_chat(prompt:str, systemcmd:str='')->str:
    messages= [   {     "role": "user", "content": prompt}         ]
    if systemcmd:
        messages.insert(0,            {     "role": "system", "content": systemcmd}            )
    completion = openai.ChatCompletion.create(
    model="gpt-3.5-turbo",
    messages=[   { "role": "user", "content": prompt} ]  )

    # print('DEBUG',messages,completion)
    return completion.choices[0].message.content

# Returns true if directory exists and has at least 1 file
def has_files(directory:str)->bool:
    if os.path.isdir(directory):
        if len(os.listdir(directory)) > 0:
            return True
    return False

def inject_comment(code:str, comment:str)->str:
    lines = code.split('\n')
    lines.insert(2, '# ' + comment)        
    code = '\n'.join(lines)
    return(code)


#-----------------------------

import file_lib


def generate_statements():
    print('NOTICE:  Generating statements')
    for r in file_lib.dataset:
        if (r.get('Scriptable') == 'Y') and (r.get('Statement') == ''):
            print('DEBUG',r['Title'])
            r['Statement'] = ai_generate_actionstatement(r['Title'])
    return True        

def generate_scripts():
    print('NOTICE: Generating scripts')

    tempcode = ''
    for r in file_lib.dataset:
        if (r.get('Scriptable') == 'Y') and (r.get('Statement')) and (not r.get('ScriptAvailable') and (r.get('ScriptAvailable') != 'TRUE') ):
            print('DEBUG',r['ID'],r['Statement'])
            tempcode = ai_generate_code(r['Statement'])
            
            if not tempcode:
                print('WARNING',r['ID'],'NO CODE GENERATED')
                continue

            print('DEBUG',tempcode)            
            filename= r['ID'].replace('.','_')+ '_fix.sh' 

            #  Extract the filename from the code if possible
            match = re.search(r"#.*\s+([a-zA-Z0-9-_]+\.[a-z]{2})\s*$", tempcode, re.MULTILINE)
            if match:
                filename = match.group(1)
                filename = filename.replace('-','_')
                print(f"NOTICE: Found filename {filename}")
            else:
                print('WARNING: No filename found')

            tempcode=inject_comment(tempcode, f"Finding: {r['ID']} {r['Title']}")

            filedir= file_lib.SCRIPTS_DIR + '/' +  r['ID'] 
           
            print(f'NOTICE: Creating directory {filedir} file {filename}')            
            os.makedirs(filedir,exist_ok=True)
            with open(filedir + '/' + filename, "w") as f:
                f.write(tempcode)
            # break

            r['ScriptAvailable'] = True
    return True        

def detect_has_scripts():
    for r in file_lib.dataset:
        # print('DEBUG',r['ID'])
        r['ScriptAvailable'] = has_files(file_lib.SCRIPTS_DIR + '/' +  r['ID'])

def experiment():
    tempcode="""
#!/bin/bash
# filename: api_gateway_cache_encryption.sh
# Finding: APIGateway.5 API Gateway REST API cache data should be encrypted at rest

#Review API Gateway REST API cache data
aws apigateway get-rest-api --rest-api-id API_GATEWAY_REST_API_ID --query 'caching.enabled'

#Enable encryption at rest if needed
aws apigateway update-rest-api --rest-api-id API_GATEWAY_REST_API_ID --patch-operations op=replace,path=/endpointConfiguration/types/EDGE/enabled,value=true --query 'endpointConfiguration.types.EDGE.enabled'


"""    
    match = re.search(r"#.*\s+([a-zA-Z0-9-_]+\.[a-z]{2})\s*$", tempcode, re.MULTILINE)
    if match:
        filename = match.group(1)
        print(f"NOTICE:  Found filename {filename}")
    else:
        print('ERROR:  No filename found')
    

def mainloop():
    file_lib.load_data()
    generate_statements()
    detect_has_scripts()
    generate_scripts()
    file_lib.save_data()

mainloop()
# experiment()
