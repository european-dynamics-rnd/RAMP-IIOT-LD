from oauth2_client.credentials_manager import CredentialManager, ServiceInformation, OAuthError
import logging


localKeycloakServer='fiware-keycloak.freeddns.org:8443'
keycloakClient='orion-pep'
keycloakClientSecret='yWv2aRCm3KKMGrj9lMXQcEXY4v80tcFk'

class NoNewlineFileHandler(logging.FileHandler):
    def emit(self, record):
        # Use the same format as the base class to prepare the record
        message = self.format(record)
        # Open the file in write mode ('w') which truncates the file
        with open(self.baseFilename, 'w') as file:
            file.write(message)  # Write the message without a newline

file_logger = logging.getLogger('file_logger')
file_logger.setLevel(logging.INFO)
file_logger.propagate = False

# Add our custom file handler without newlines
file_handler = NoNewlineFileHandler('token.txt', mode='w')
formatter = logging.Formatter('%(message)s')
file_handler.setFormatter(formatter)
file_logger.addHandler(file_handler)

scopes = ['openid']

_logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.WARNING, format='%(levelname)5s - %(name)s -  %(message)s')

service_information = ServiceInformation('https://'+localKeycloakServer+'/realms/fiware-server/protocol/openid-connect/auth',
                                         'https://'+localKeycloakServer+'/realms/fiware-server/protocol/openid-connect/token',
                                         keycloakClient,
                                         keycloakClientSecret,
                                          scopes)
manager = CredentialManager(service_information)
redirect_uri = 'http://localhost:8080/oauth/code'   

# Builds the authorization url and starts the local server according to the redirect_uri parameter
url = manager.init_authorize_code_process(redirect_uri, 'state_test')
_logger.warning('Open this url in your browser\n%s', url)

code = manager.wait_and_terminate_authorize_code_process()
# From this point the http server is opened on 8080 port and wait to receive a single GET request
# All you need to do is open the url and the process will go on
# (as long you put the host part of your redirect uri in your host file)
# when the server gets the request with the code (or error) in its query parameters
manager.init_with_authorize_code(redirect_uri, code)
# _logger.debug('Access got = %s', manager._access_token)
file_logger.info(manager._access_token)
























# _logger.debug('Code got = %s', code)
# manager.init_with_authorize_code(redirect_uri, code)
# _logger.debug('Access got = %s', manager._access_token)
# openIDManager=OpenIdCredentialManager(manager)
# _logger.debug('Access got !!!!! = %s', openIDManager._access_token)




# Here access and refresh token may be used with self.refresh_token