import urllib3
import utils
from dotenv import dotenv_values
import pytest
import os

# Disable warnings about unverified HTTPS requests
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)
  
config_env_filepath = os.getenv('RAMP_IOT_TESTING_ENV_PATH', default='../.env')
config_env_secrets_filepath = os.getenv('RAMP_IOT_TESTING_ENV_SECRETS_PATH', default='./credentials.txt')
localhost = os.getenv('RAMP_IOT_TESTING_LOCALHOST', default=True)

config = dotenv_values(config_env_filepath)
config.update(dotenv_values(config_env_secrets_filepath))
config['MULTI_TENANT'] = False


orion_ld_hostname = utils.get_container_hostname_by_name(r"orion", localhost)
orion_url="http://"+orion_ld_hostname+":"+config["ORION_LD_PORT"]

mintaka_hostname = utils.get_container_hostname_by_name(r"mintaka", localhost)
mintaka_url="http://"+mintaka_hostname+":"+config["MINTAKA_PORT"]

sensor='urn:ngsi-ld:ramp-iot:device-id-001'

def test_orion_ld_noauth():
    
    orion_version_endpoint=orion_url+"/version"
    # print(orion_version_endpoint)
    # get version of orion
    assert utils.count_characters_in_json(orion_version_endpoint, config) == True
    # add some data
    assert utils.orion_upsert_data(orion_url,"device-id-001.json",config) == True
    orion_url_sensor=orion_url+'/ngsi-ld/v1/entities/'+sensor
    # read the added data
    # print(orion_url_sensor)
    assert utils.count_characters_in_json(orion_url_sensor, config, False, 200) == True

def test_orion_ld_auth():
    orion_token=utils.get_orion_token(config)
    assert len(orion_token)>1000
    kong_hostname = utils.get_container_hostname_by_name(r"kong", localhost)
    # count_characters_in_json_auth
    kong_orion_endpoint='https://'+kong_hostname+':'+config["KONG_PORT"]+'/keycloak-orion'
    kong_orion_endpoint_version=kong_orion_endpoint+'/version'
    # get version
    assert utils.count_characters_in_json_auth(kong_orion_endpoint_version, orion_token,config) == True
    kong_orion_url_sensor=kong_orion_endpoint+'/ngsi-ld/v1/entities/'+sensor
    # get data from orion
    assert utils.count_characters_in_json_auth(kong_orion_url_sensor, orion_token,config) == True

def test_mintaka_noauth():

    mintaka_info_endpoint=mintaka_url+"/info"
    assert utils.count_characters_in_json(mintaka_info_endpoint, config) == True
    mintaka_sensor_endpoint=mintaka_url+"/temporal/entities/"+sensor
    assert utils.mintaka_sensor_data(mintaka_sensor_endpoint,config,"lastN=1")    

def test_mintaka_auth():
    mintaka_token=utils.get_mintaka_token(config)
    assert len(mintaka_token)>1000
    kong_hostname = utils.get_container_hostname_by_name(r"kong", localhost)
    # count_characters_in_json_auth
    kong_mintaka_url='https://'+kong_hostname+':'+config["KONG_PORT"]+'/keycloak-mintaka'
    kong_mintaka_endpoint_info=kong_mintaka_url+'/info'
    # get version
    assert utils.count_characters_in_json_auth(kong_mintaka_endpoint_info, mintaka_token,config) == True
    kong_mintaka_sensor_endpoint=kong_mintaka_url+"/temporal/entities/"+sensor
    assert utils.mintaka_sensor_data(kong_mintaka_sensor_endpoint,config,"lastN=1",mintaka_token)    

def test_multi_tenant():
    # add multi tenant configuration
    config['MULTI_TENANT'] = True
    config['MULTI_TENANT_NAME']='openiot'
    test_orion_ld_noauth()
    test_orion_ld_auth()
    test_mintaka_noauth()
    test_mintaka_auth()

def test_cleanup():
    assert utils.orion_cleanup(orion_url,sensor,config) == True
    # remove temporal representation of sensors
    # troe_sensor_endpoint=orion_url+"/ngsi-ld/v1/temporal/entities/"+sensor
    # No implemented 20240226 on Orion-LD
    # assert utils.troe_cleanup(troe_sensor_endpoint,config) == True
    
# If you want to run this script directly using Python instead of pytest,
# you can use the following block. Otherwise, it's not needed when running with pytest.
if __name__ == "__main__":
    test_orion_ld_noauth()
    test_orion_ld_auth()
    test_mintaka_noauth()
    test_mintaka_auth()
    test_multi_tenant()
    test_cleanup()