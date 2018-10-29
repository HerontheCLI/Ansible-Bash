#!/bin/bash 

#install ansible
yum install wget -y
wget http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-8.noarch.rpm
rpm -ivh epel-release-7-8.noarch.rpm
yum install ansible -y

cd $HOME
mkdir -p ansible-nginx/tasks/
touch ansible-nginx/deploy.yml
touch ansible-nginx/tasks/install_nginx.yml

#populate deploy.yml

echo -e "# ./ansible-nginx/deploy.yml
- hosts: localhost
  tasks:
    - include: 'tasks/install_nginx.yml'" > $HOME/ansible-nginx/deploy.yml

#populate install_nginx.yml

echo -e "# ./ansible-nginx/tasks/install_nginx.yml
 
- name: NGINX | Installing NGINX repo rpm
  yum:
    name: http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm
 
- name: NGINX | Installing NGINX
  yum:
    name: nginx
    state: latest
 
- name: NGINX | Starting NGINX
  service:
    name: nginx
    state: started
" > $HOME/ansible-nginx/tasks/install_nginx.yml


#install nginx
sudo ansible-playbook -c local $HOME/ansible-nginx/deploy.yml

#populate with index.html

echo -e "<html>
  <head>
    <title>NWEA tech_quiz sample index.html</title>
  </head>
  <body bgcolor=white>
    <table border="0" cellpadding="10">
      <tr>
        <td>
          <h1>Hello, this is the sample page</h1>
        </td>
      </tr>
    </table>
  </body>
</html>" > /usr/share/nginx/html/index.html

#edit default.conf to listen on port 8888
sed -i -e 's/80/8888/g' /etc/nginx/conf.d/default.conf

#configure se linux to allow systemctl to function
semanage permissive -a "httpd_t"

#reload nginx
systemctl restart nginx.service
