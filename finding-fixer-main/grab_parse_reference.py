#!/usr/bin/env python3

from urllib.parse import urljoin
import requests
from bs4 import BeautifulSoup
import csv
import re
import json

# specify the URL of the webpage to be scraped
url = 'https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-controls-reference.html'

# send a GET request to the URL and get the HTML content
response = requests.get(url)
html_content = response.content


# create a BeautifulSoup object from the HTML content
soup = BeautifulSoup(html_content, 'html.parser')

# find the first big table on the webpage
big_table = soup.find('table', {'id': 'w390aac31c25c11'})

if not big_table:
    print('No reference table found')
    exit()

# get the header row of the big table
header_row = big_table.find('tr')

# find the index of the columns to extract based on their header row title
col1_index = None
col2_index = None
cols = header_row.find_all('th')
for i in range(len(cols)):
    print(f"*{cols[i].text.strip()}*")  # print the header row title for debugging purpose
    if cols[i].text.strip() == 'Security control ID':
        col1_index = i
    elif cols[i].text.strip() == 'Security control title':
        col2_index = i

if (col1_index==None) or (col2_index==None):
    print('No columns found')
    exit()

outputlist=[]
# extract the columns based on their index in each row of the big table
rows = big_table.find_all('tr')
for row in rows[1:]:  # skip the header row
    cols = row.find_all('td')
    if len(cols) > max(col1_index, col2_index):
        col1 = cols[col1_index]
        link=''
        if col1.find('a'):
            link = col1.find('a').get('href')
            # check if the link is an absolute URL
            if not link.startswith('http'):
                link = urljoin(url, link)
            value = col1.text.strip()
            print(link)

        txtID = col1.text.strip()
        
        col2 = cols[col2_index].text.strip()
    # Clean up weird whitespace in the title column
    col2 = re.sub(r'\s+', ' ', col2)
    # Add the extracted columns to the output list
    outputlist.append({'ID': txtID, 'Title': col2, 'Link': link})

# print(outputlist)
# write the output list to a csv file
with open('findings.csv', 'w', newline='') as csvfile:
    fieldnames = outputlist[0].keys()
    writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
    writer.writeheader()
    for row in outputlist:
        writer.writerow(row)

# # Write outputlist to a json file
# with open('findings.json', 'w') as jsonfile:
#     json.dump(outputlist, jsonfile, indent=4)
    
