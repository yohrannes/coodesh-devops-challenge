import requests
import subprocess
import os


username = "yohrannes"
repo_name = "website-portifolio"

url = f"https://api.github.com/repos/{username}/{repo_name}/commits"
response = requests.get(url)

if response.status_code == 200:
    data = response.json()
    latest_commit_sha = data[0]['sha']
    workdir = "/root/website-portifolio"
    os.chdir(workdir)
    actual_commit_sha = os.popen('git rev-parse HEAD').read().strip()
    print(f"{actual_commit_sha}", "-> local website commit")
    print(f"{latest_commit_sha}", "-> latest website commit on github")
    getdate = "date"
    os.system(getdate)
else:
    print(f"{response.status_code}")
    
if actual_commit_sha != latest_commit_sha:
    print ("updating website folders....")
    workdir = "/root/website-portifolio"
    os.chdir(workdir)
    command = "git fetch origin main;git pull origin main;echo 'updated at '$(date)"
    os.system(command)
else:
    print ("commits up-to-date")
