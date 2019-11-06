from typing import Dict, Optional

import json
import datetime
import urllib.request

def datadog_metric(name: str, value, tags: Optional[Dict] = None) -> Dict:

    if tags is None:
        tags = {}

    return json.dumps({
        'm': name,
        'v': value,
        'e': int(datetime.datetime.now().timestamp()),
        't': [f'{k}:{v}' for k, v in tags.items()]
    })

def graphql_request(url: str, query: str, operationName: str='', variables: Dict[str, str]=None) -> Dict:

    body = {
        'query': query,
        'operationnName': operationName,
        'variables': variables if variables is not None else {}
    }

    request = urllib.request.Request(
        url,
        data=json.dumps(body).encode(),
        headers={
            'Content-Type': 'application/json'
        },
        method='POST'
    )
    response = urllib.request.urlopen(request)
    return json.loads(response.read())

def get_stats(orb: str) -> Dict[str, int]:

    query = '{orb(name: "' + orb + '''") {
        name,
        statistics {
            last30DaysBuildCount,
            last30DaysOrganizationCount,
            last30DaysProjectCount
        }
    }
}'''

    response = graphql_request('https://circleci.com/graphql-unstable', query)

    return response['data']['orb']['statistics']

def log_orb_stats(orb):
    stats = get_stats(orb)
    for name, value in stats.items():
        print(datadog_metric(f'circleci.orb.{name}', value, tags={'orb': orb}))

def handler(event, context):
    log_orb_stats('ovotech/terraform')
    log_orb_stats('ovotech/clair-scanner')

if __name__ == '__main__':
    handler({}, None)
