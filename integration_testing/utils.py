
import docker
import re
import requests
import urllib3
import json

def get_container_hostname_by_name(name,localhost=False):
    if (localhost): return "localhost"
    client = docker.from_env()
    # Fetch all running containers
    running_containers = client.containers.list()
    # Define the regular expression for matching 'orion-ld'
    pattern = re.compile(name)
    for container in running_containers:
        image_tags = " ".join(container.image.tags)
        if pattern.search(image_tags):
            # print(container.attrs['Config']['Hostname'])
            return container.attrs['Config']['Hostname']
        else:
            return ""

def count_characters_in_json(endpoint, config, showJSON=False,number_of_characters=50):
    # Fetch the response from the endpoint
    headers = {
    'Accept-Encoding': None
    }
    if config['MULTI_TENANT']:
        headers['NGSILD-Tenant']=config['MULTI_TENANT_NAME']
        
    response = requests.get(endpoint, headers=headers)
    # print(response.request.headers)
    if response.status_code != 200:
        print("Failed to fetch data from the endpoint.")
        return False
    # Convert response to text
    json_text = response.text
    # Count the number of characters
    response_num_characters = len(json_text)
    print(f"The JSON response contains {response_num_characters} characters.")
    if showJSON:
        print(json_text)
    if response_num_characters>number_of_characters:
        return True
    else:
        return False
    
def count_characters_in_json_auth(endpoint,token, config, showJSON=False,number_of_characters=50):
    headers = {
        'Authorization': 'Bearer ' + token + ' ',
    }
    if config['MULTI_TENANT']:
        headers['NGSILD-Tenant']=config['MULTI_TENANT_NAME']
    # Fetch the response from the endpoint
    host = config['HOST']
    if host == 'localhost':
        secure =False
    else:
        secure=True
    # print(endpoint)
    response = requests.get(endpoint,headers=headers, verify=secure)
    if response.status_code != 200:
        print("Failed to fetch data from the endpoint.")
        return False
    # Convert response to text
    json_text = response.text
    # Count the number of characters
    response_num_characters = len(json_text)
    print(f"The JSON response contains {response_num_characters} characters.")
    if showJSON:
        print(json_text)
    if response_num_characters>number_of_characters:
        return True
    else:
        return False
    
    
def get_mintaka_token(config):
    urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)
    # Determine security mode based on the HOST
    host = config['HOST']
    if host == 'localhost':
        secure =False
    else:
        secure=True
    # Construct the request URL and data
    url = f"https://{config['HOST']}:{config['KEYCLOAK_TLS_PORT']}/realms/fiware-server/protocol/openid-connect/token"
    data = {
        'username': config['KEYCLOAK_CLIENT_USERNAME'],
        'password': config['KEYCLOAK_CLIENT_PASSWORD'],
        'grant_type': 'password',
        'client_id': config['KEYCLOAK_MINTAKA_CLIENT_ID'],
        'client_secret': config['KEYCLOAK_MINTAKA_CLIENT_SECRET']
    }

    # Make the POST request to the Keycloak token endpoint
    response = requests.post(url, data=data, verify=secure,  timeout=25)
    response.raise_for_status()  # Will raise an HTTPError if the HTTP request returned an unsuccessful status code
    if response.status_code != 200:
        print("Failed to fetch data from the endpoint.")
        return None
    # Extract the access token from the response
    # print(response.json())
    token = response.json().get('access_token')
    return token

def get_orion_token(config):
    urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)
    # Determine security mode based on the HOST
    host = config['HOST']
    if host == 'localhost':
        secure =False
    else:
        secure=True
    # Construct the request URL and data
    url = f"https://{config['HOST']}:{config['KEYCLOAK_TLS_PORT']}/realms/fiware-server/protocol/openid-connect/token"
    data = {
        'username': config['KEYCLOAK_CLIENT_USERNAME'],
        'password': config['KEYCLOAK_CLIENT_PASSWORD'],
        'grant_type': 'password',
        'client_id': config['KEYCLOAK_ORION_CLIENT_ID'],
        'client_secret': config['KEYCLOAK_ORION_CLIENT_SECRET']
    }

    # Make the POST request to the Keycloak token endpoint
    response = requests.post(url, data=data, verify=secure,  timeout=25)
    response.raise_for_status()  # Will raise an HTTPError if the HTTP request returned an unsuccessful status code
    if response.status_code != 200:
        print("Failed to fetch data from the endpoint.")
        return False
    # Extract the access token from the response
    # print(response.json())
    token = response.json().get('access_token')
    return token

def orion_upsert_data(url,json_file_name,config):

    headers = {
        'Content-Type': 'application/ld+json',
        'Accept': 'application/json',
    }
    if config['MULTI_TENANT']:
        headers['NGSILD-Tenant']=config['MULTI_TENANT_NAME']
    with open("./json/"+json_file_name, 'r') as file:
        data = json.load(file)
    # print(data)
    response = requests.post(url+'/ngsi-ld/v1/entityOperations/upsert', headers=headers, json=[data])  
    print(response)
    if response.status_code >= 200 & response.status_code < 300:
        return True
    else:
        print("Failed to fetch data from the endpoint.")
        return False


def orion_cleanup(url,sensor_name,config):
    # no multi-tennand 
    headers = {
    }

    response = requests.delete(url+'/ngsi-ld/v1/entities/'+sensor_name, headers=headers)
    print(response)
    if response.status_code >= 200 & response.status_code < 300:
        return True
    else:
        print("Failed to delete entrity: "+sensor_name)
        return False
    headers['NGSILD-Tenant']=config['MULTI_TENANT_NAME']
    response = requests.delete(url+'/ngsi-ld/v1/entities/'+sensor_name, headers=headers)
    print(response)
    if response.status_code >= 200 & response.status_code < 300:
        return True
    else:
        print("Failed to delete entrity: "+sensor_name)
        return False
    return True



def mintaka_sensor_data(url,config,data,token="",number_of_characters=20): 
    
    headers = {
        'Link': '<' + config['CONTEXT'] + '>; rel="http://www.w3.org/ns/json-ld#context"; type="application/ld+json"',
    }
    if config['MULTI_TENANT']:
        headers['NGSILD-Tenant']=config['MULTI_TENANT_NAME']
    if (len(token)>10):
        headers['Authorization']='Bearer ' +token + ' '
    host = config['HOST']
    if host == 'localhost':
        secure =False
    else:
        secure=True
    response = requests.get(url, headers=headers,data=data, verify=secure)  
    print(response)
    if response.status_code >= 200 & response.status_code < 300:
        json_text = response.text
        # Count the number of characters
        response_num_characters = len(json_text)
        print(f"The JSON response contains {response_num_characters} characters.")
        if response_num_characters>number_of_characters:
            return True
        else:
            return False
    else:
        print("Failed to fetch data from the endpoint.")
        return False


def troe_cleanup(url,config):
    # no multi-tennand 
    headers = {
    }
    print(url)
    response = requests.delete(url, headers=headers)
    print(response)
    headers['NGSILD-Tenant']=config['MULTI_TENANT_NAME']
    response = requests.delete(url, headers=headers)
    print(response)
    return True