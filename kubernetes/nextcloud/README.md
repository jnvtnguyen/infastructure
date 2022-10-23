apiVersion: v1
kind: Secret
metadata:
  name: nextcloud-database
  namespace: nextcloud
data:
  user: <user>
  password: <password>
  root_password: <root_password>
