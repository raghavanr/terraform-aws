import os
import subprocess
import sys, json
import requests

def workspacevariable(WorkSpaceID, Provider, Token, OrganizationName, WorkspaceName):
    if os.name == 'nt':
        os.system("cls")
    else:
        os.system("clear")
    print("\n##########################################################################################\n")
    print("Script Execution Started")
    try:
        # Getting Environment variable from run
        f = open("variables.txt", "a+")
        a = subprocess.Popen("env | grep 'bamboo_" + Provider + "_*'", shell=True, stdout=subprocess.PIPE).stdout
        b = a.read()
        b = b.decode("utf-8")
        b = b.split("\n")
        b.pop()
        c = []
        env_vars = {}
        for i in b:
            c.append(i.split("="))
        for i in c:
            env_vars[i[0].replace('bamboo_', '')] = i[1]
        print(env_vars)
        for key in env_vars:
            if 'secret' in key:
                print("\033[1;32m")
                payload = dict(data = dict(attributes = dict(key=key, value=env_vars[key], category="terraform", hcl=False, sensitive=True), relationships=dict(workspace=dict(data=dict(id=WorkSpaceID, type="workspaces")))), type="vars")
    # Creating Header content for POST request
                headers_content = '{"Authorization" : "Bearer  ' + Token + '", "Content-Type" : "application/vnd.api+json", "charset" : "utf-8" }'
                headers = json.loads(headers_content)
                url = "https://app.terraform.io/api/v2/vars"
                try:
                    result = requests.post(url, json = payload, headers = headers, allow_redirects = False)
                    if result.status_code in range(200, 202):
                        f.write(key + "=" + (json.loads(result.content))['data']['id'] + "\n")
                        print(key + "=" + (json.loads(result.content))['data']['id'])
                        print("\033[1;32mVariable " + key + " Successfully uploaded to Workspace...\033[0m")
                    elif result.status_code == 422:
                        print("\033[1;32mGetting Variable Information...")
                        url = "https://app.terraform.io/api/v2/vars?filter%5Borganization%5D%5Bname%5D=" + OrganizationName + "&filter%5Bworkspace%5D%5Bname%5D=" + WorkspaceName
                        headers_content = '{"Authorization" : "Bearer  ' + Token + '", "Content-Type" : "application/vnd.api+json", "charset" : "utf-8" }'
                        headers = json.loads(headers_content)
                        get = requests.get(url, headers = headers, allow_redirects = False)
                        json_object = (json.loads(get.content))['data']
                        for id in json_object:
                            f.write((id)['attributes']['key'] + "=" + (id)['id'] + "\n")
                            print("\033[1;32m" + (id)['attributes']['key'] + "=" + (id)['id'] + "\033[0m")
                    else:
                        print("\033[1;31mError : " + str(result.status_code) + "\033[0m")
                        print('\033[0m')
                except Exception as e:
                    print("\033[1;31mError : " + str(e) + "\033[0m")
            else:
                payload = dict(data=dict(attributes=dict(key=key, value=env_vars[key], category="terraform", hcl=True, sensitive=False), relationships=dict(workspace=dict(data=dict(id=WorkSpaceID, type="workspaces")))), type="vars")
    # Creating Header content for POST request
                headers_content = '{"Authorization" : "Bearer  ' + Token + '", "Content-Type" : "application/vnd.api+json", "charset" : "utf-8"}'
                headers = json.loads(headers_content)
                url = "https://app.terraform.io/api/v2/vars"
                result = requests.post(url, json=payload, headers=headers, allow_redirects=False)
                if result.status_code in range(200, 202):
                    f.write(key + "=" + (json.loads(result.content))['data']['id'] + "\n")
                    print("\033[1;32mVariable " + key + " Successfully uploaded to Workspace...\033[0m")
                print('\033[0m')
    except Exception as e:
        print("\033[1;31mError : " + str(e) + "\033[0m")
    finally:
        f.close()
        print("Script Execution Completed, Variables Successfully Pushed")
        print("\n##########################################################################################\n")


def main():
    workspaceid = sys.argv[1]
    provider = sys.argv[2]
    token = sys.argv[3]
    organizationname = sys.argv[4]
    workspacename = sys.argv[5]
    workspacevariable(workspaceid, provider, token, organizationname, workspacename)
main()