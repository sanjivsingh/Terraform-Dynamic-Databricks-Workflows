import json
import sys
        
def _get_notebooks(data):

    result = {
        'job_name': json.dumps(data["job_name"]),
        'notebooks': json.dumps(data["notebooks"]),
        'notebooks_dependency': json.dumps(data["notebooks_dependency"])
    }
    return result


def parse_onboarding_json(onboarding_json):
    f = open(onboarding_json)
    data = json.load(f)
    result = _get_notebooks(data)
    print(json.dumps(result))


if __name__ == "__main__":
    try:
        input = sys.stdin.read()
        input_json = json.loads(input)
        parse_onboarding_json(onboarding_json=input_json.get('onboarding_json'))
    except Exception as e:
        sys.stderr.write(str(e))
        raise Exception