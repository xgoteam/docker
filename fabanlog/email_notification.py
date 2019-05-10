import sys
import os
import datetime
import gitlab
import logging
import time
from email_sender.mail import send

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s : %(levelname)s : %(message)s',
    datefmt='%Y-%m-%d %a %H:%M:%S',
    filename='/work/log/out.log'
)

def send_email(project_name, tag):
    at = time.time()
    gl = gitlab.Gitlab(os.getenv('GITLAB_HOST'), private_token=os.getenv('ACCESS_TOKEN'))
    projects = gl.projects.list(search=project_name)
    for project in projects:
        if 'deploy.' not in project.name:
            project = project

    project_name = project.name

    tag_obj = project.tags.get(tag)
    tag_msg = tag_obj.message
    project_address = project.web_url

    log_info = f'{project_name}|{project_address}|{at}|master|{tag}|{tag_msg}'
    logging.info(log_info)
    
    at_datetime = datetime.datetime.fromtimestamp(at).strftime('%Y-%m-%d %H:%M:%S')
    user_list = set()
    users = project.users.list(all=True)
    for user in users:
        user_list.add(user.username)

    email_list = []
    for u in user_list:
        user = gl.users.list(username=u)[0]
        email_list.append((user.name, user.email))

    email_title = f'发版 {project_name}'

    for name,email in email_list:
        if 'hiii-life.com' in email:
            email = email.replace('hiii-life.com', 'xgo.one')

        email_msg = f'''
Dear {name}：<br>
    项目 {project_name} 在 {at_datetime} 进行了发版操作。<br>
    仓库地址: {project_address}<br>
    分支: master<br>
    tag: {tag}<br>
    tag内容: {tag_msg}
'''
        # print(email_title)
        # print(email)
        # print(email_msg)
        # print('*'*30)
        send(email_msg, email_title, email)

if __name__ == '__main__':
    project_name, tag = sys.argv[1:3]
    send_email(project_name, tag)