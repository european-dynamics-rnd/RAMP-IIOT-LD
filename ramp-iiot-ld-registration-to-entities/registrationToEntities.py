from flask import Flask, request, Response, stream_with_context
import requests

from http.server import BaseHTTPRequestHandler, HTTPServer
import os
import re
import logging
import json
import threading
from datetime import datetime, timezone

log_level = os.getenv('LOG_LEVEL', 'ERROR').upper()
# Configure logging
logging.basicConfig(
    level=getattr(logging, log_level, logging.ERROR),
    format='%(asctime)s- %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

DEFAULT_CONTEXT=os.getenv('DEFAULT_CONTEXT','http://ramp_iiot_ld-ld-context/ramp_iiot_ld-context.jsonld')
HOST =os.getenv('PROXY_HOST','0.0.0.0')
PORT =os.getenv('PROXY_PORT',8888) 
HTTP_SERVICES_BROKER_URL=os.getenv('HTTP_SERVICES_BROKER_URL','https://ramp_iiot_ld-platform.eurodyn.com/kong/keycloak-orion/ngsi-ld/v1/entityOperations/upsert') 
KEYCLOCK_URL = os.getenv('KEYCLOCK_URL', "https://ramp_iiot_ld-platform.eurodyn.com/idm/realms/fiware-server/protocol/openid-connect/token")

USERNAME=os.getenv('USERNAME',"")
PASSWORD=os.getenv('PASSWORD',"")
CLIENT_SECRET=os.getenv('CLIENT_SECRET',"")
OVERWRITE_NGSILD_TENANT=os.getenv('OVERWRITE_NGSILD_TENANT',"")


runtime_state_lock = threading.Lock()
runtime_state = {
    "started_at": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
    "last_proxy_request_at": None,
    "last_upstream_status": None,
    "last_upstream_error": None,
}


def now_iso():
    return datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")


def set_runtime_state(**kwargs):
    with runtime_state_lock:
        runtime_state.update(kwargs)


def get_runtime_state():
    with runtime_state_lock:
        return dict(runtime_state)

# GENERAL_TENANT=test_federation

def get_token_ramp_iiot_ld():

    payload = f'username={USERNAME}&password={PASSWORD}&grant_type=password&client_id=orion-pep&client_secret={CLIENT_SECRET}'
    headers = {
    'Content-Type': 'application/x-www-form-urlencoded'
    }
    try:
        response = requests.request("POST", KEYCLOCK_URL, headers=headers, data=payload)
        response.raise_for_status()
        # Log the response for debugging
        logger.info('Response status code: %s', response.status_code)
        logger.debug('Response body: %s', response.text)
    except requests.exceptions.RequestException as req_err:
        response_json['access_token']=""
        logger.error(f'Request error occurred: {req_err}')
    except Exception as err:
        response_json['access_token']=""
        logger.error(f'An unexpected error occurred: {err}')
    else:
        # Process the response if needed
        logger.debug(response.json())  # Example of processing the res
        response_json=response.json()
        logger.debug(response_json['access_token'])
        
    return response_json['access_token']

def extract_data_inside_angle_brackets(text):
    """
    Extract the data inside angle brackets <> from the given text.
    If no data is found, return an empty string.
    
    :param text: The input string containing the angle brackets
    :return: A string found inside the angle brackets, or an empty string if not found
    """
    pattern = r'<(.*?)>'
    matches = re.findall(pattern, text)
    return matches[0] if matches else ""
    
def fromRegistrationToEntity(registration_json):
    
    if 'data' in registration_json:
        # if not '@context' in ['data'][0]:
        #     registration_json['data'][0]['@context']=CONTEXT
        return registration_json['data'][0]
    else:
        logger.error("empty entity from registration",registration_json)
        return -1


app = Flask(__name__)


@app.route('/health', methods=['GET'])
@app.route('/healthz', methods=['GET'])
def health():
    state = get_runtime_state()
    upstream_status = state.get("last_upstream_status")
    healthy = upstream_status is None or 200 <= upstream_status < 500

    payload = {
        "status": "ok" if healthy else "degraded",
        "service": "registration-to-entities",
        "last_proxy_request_at": state.get("last_proxy_request_at"),
        "last_upstream_status": upstream_status,
        "last_upstream_error": state.get("last_upstream_error"),
        "started_at": state.get("started_at"),
        "checked_at": now_iso(),
    }
    return payload, (200 if healthy else 503)

@app.route('/proxy', methods=[ 'POST'])
def proxy():
    # Ensure the URL has a scheme
    logger.info(request)
    set_runtime_state(last_proxy_request_at=now_iso())
    # Get the method of the request
    method = request.method

    # Get the headers from the original request
    headers = {key: value for (key, value) in request.headers.items() if key not in ['Host', 'Content-Length','User-Agent']}
    # headers['Link'] <http://ld-context/ed-context.jsonld>; rel="http://www.w3.org/ns/json-ld#context"; type="application/ld+json"
    context=extract_data_inside_angle_brackets(headers['Link'])
    if context == "":
        context=DEFAULT_CONTEXT
        headers.pop('Link', None)
        
    # Get the data from the original request
    data = request.json
    # data=json.loads(data)
    data=fromRegistrationToEntity(data)
    id=data['id']
    data=f"[{json.dumps(data)}]"
    
    token=get_token_ramp_iiot_ld()
    headers["Authorization"] = "Bearer " + token
    
    # Override NGSILD-Tenant header if environment variable is set
    if OVERWRITE_NGSILD_TENANT:
        headers["NGSILD-Tenant"] = OVERWRITE_NGSILD_TENANT
    
    
    url=HTTP_SERVICES_BROKER_URL
    logger.info(f"Sending request:")
    logger.debug(f"  Method: {method}")
    logger.info(f"  URL: {url}/{id}")
    logger.debug(f"  Headers: {headers}")
    logger.debug(f"  data: {data}")

    try:
        # Make the request to the target server
        resp = requests.request(
            method=method,
            url=url,
            headers=headers,
            data=data,
            stream=True,
            allow_redirects=False
        )
        # Log the response details
        logger.info(f"Received response Status: {resp.status_code}")
        logger.debug(f"  Headers: {dict(resp.headers)}")
        set_runtime_state(last_upstream_status=resp.status_code, last_upstream_error=None)
        # Create a response object
        proxied_response = Response(
            stream_with_context(resp.iter_content(chunk_size=8192)),
            content_type=resp.headers.get('Content-Type'),
            status=resp.status_code
        )

        # Add headers from the proxied response
        for header, value in resp.headers.items():
            if header.lower() not in ('transfer-encoding', 'content-encoding'):
                proxied_response.headers[header] = value

        return proxied_response

    except requests.RequestException as e:
        set_runtime_state(last_upstream_status=503, last_upstream_error=str(e))
        logger.error(f"Error forwarding request: {str(e)}")
        return f"Error forwarding request: {str(e)}", 500
    
if __name__ == '__main__':
    app.run(host=HOST, port=PORT, debug=True)
