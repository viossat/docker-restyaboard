# viossat/restyaboard

Open source, Trello like Kanban board, based on Restya platform.
http://restya.com/board

## `docker-compose.yml`

```
restyaboard:
  image: viossat/restyaboard
  ports:
    - "80:80"
  volumes: # optional
    - /volume/path/config:/etc/restyaboard
    - /volume/path/media:/var/www/html/media
  links:
    - postgres
    - elasticsearch # optional
  environment:
    - DB_HOST=postgres
    - DB_PORT=5432 # optional, default: 5432
    - DB_USER=restyaboard
    - DB_PASSWORD=restyaboard # optional, default: DB_USER
    - DB_NAME=restyaboard # optional, default: restyaboard
postgres:
  image: postgres
  volumes: # optional
    - /volume/path/postgres:/var/lib/postgresql/data
  environment:
    - POSTGRES_USER=restyaboard
    - POSTGRES_PASSWORD=restyaboard
elasticsearch: # optional
  image: elasticsearch
  volumes: # optional
    - /volume/path/elasticsearch:/usr/share/elasticsearch/data
```

## Default users

```
Username: admin
Password: restya

Username: user
Password: restya
```
