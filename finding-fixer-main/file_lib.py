#!/usr/bin/env python3

import csv
import re
import json

FILE_NAME_CSV="findings.csv" 
FILE_NAME_JSON="findings.json"
SCRIPTS_DIR="output/"

dataset=[]

def load_data():
 global dataset
 print("Loading data from file: ", FILE_NAME_CSV)
 dataset=read_csv(FILE_NAME_CSV)


def save_data():
    global dataset
    # write_json(dataset, FILE_NAME_JSON)
    write_csv(dataset, FILE_NAME_CSV)

def read_csv(fn:str):
    with open(fn, 'r') as csvfile:
        reader = csv.DictReader(csvfile)
        rows = [row for row in reader]
        return rows

def write_json(data, fn:  str):
    with open(fn, 'w') as jsonfile:
        json.dump(data, jsonfile, indent=4)

def write_csv(data: any, fn: str):
    with open(fn, 'w') as csvfile:
        fieldnames = data[0].keys()
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        for row in data:
            writer.writerow(row)

 
# def main():
#     global dataset
#     load_data()
#     print(dataset)
#     write_data()



# if __name__ == "__main__":
#     main()