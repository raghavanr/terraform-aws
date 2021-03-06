import boto3
import json
import sys
import botocore.exceptions
import time

try: 
    dynamodb = boto3.client('dynamodb', region_name='ap-south-1', aws_access_key_id=sys.argv[1], aws_secret_access_key=sys.argv[2])
    def dynamodb_table_create():
        try:
            table = dynamodb.create_table(
            TableName='terraform_data',
            KeySchema=[
                {
                'AttributeName': 'RunID',
                'KeyType': 'HASH'
                },
                {
                'AttributeName': 'Workspace',
                'KeyType': 'RANGE'
                }
            ],
            AttributeDefinitions=[
                {
                    'AttributeName': 'Workspace',
                    'AttributeType': 'S'
                },
                {
                    'AttributeName': 'RunID',
                    'AttributeType': 'S'
                }
            ],
            ProvisionedThroughput={
                'ReadCapacityUnits': 5,
                'WriteCapacityUnits': 5
            }
            )
            print("TableARN: " + str(table['TableDescription']['TableArn']))
            print("TableID: " + str(table['TableDescription']['TableId']))
            print("TableRequestID: " + str(table['ResponseMetadata']['RequestId']))
            print("TableCreationDate: " + str(table['TableDescription']['CreationDateTime']))
            time.sleep(8)
            dynamodb_put_data('RunID', sys.argv[3], 'Vars', sys.argv[4])
        except dynamodb.exceptions.ResourceInUseException as e:
            print("Table exists already,")
            try:
                dynamodb_put_data('RunID', sys.argv[3], 'Vars', sys.argv[4]) 
            except Exception as ce:
                print("Unable to load data into the table, " + str(ce))
        except botocore.exceptions.ClientError as ce:
            print("Error Creating Table.." + str(ce.response['Error']['Message']))

    def dynamodb_put_data(key1, value1, key2, value2):
        try:
            dynamodb = boto3.resource('dynamodb', region_name='ap-south-1', aws_access_key_id=sys.argv[1], aws_secret_access_key=sys.argv[2])
            update_table = dynamodb.Table('terraform_data')
            json_data = {}
            json_data[key1] = value1
            json_data[key2] = value2
            json_data['config'] = 'config-dadaddfadf'
            json_data['Workspace'] = 'ws-erfgeerere'
            response = update_table.put_item(Item=json_data)
            if response['ResponseMetadata']['HTTPStatusCode'] == 200:
                print("Data updated")
            else:
                print("Data updation failed!!")
        except Exception as er:
            print("Error uploading data: " + str(er))
    
    dynamodb_table_create() 

except IndexError as ix:
            print("Error: Check the given inputs " + str(ix))
