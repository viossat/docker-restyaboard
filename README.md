# viossat/restyaboard

Open source Kanban board.
[Official website](https://restya.com/board) and [demo](https://restya.com/board/demo).

## Minimal `docker-compose.yml`

```
restyaboard:
  image: viossat/restyaboard
  ports:
    - "80:80"
  links:
    - postgres
postgres:
  image: postgres
  environment:
    - POSTGRES_USER=restyaboard
    - POSTGRES_PASSWORD=restyaboard
```

## Complete `docker-compose.yml` (Elasticsearch, persistent volumes, ...)

```
restyaboard:
  image: viossat/restyaboard
  restart: always
  ports:
    - "80:80"
  volumes:
    - /volume/path/config:/etc/restyaboard
    - /volume/path/media:/var/www/html/media
  links:
    - postgres
    - elasticsearch
postgres:
  image: postgres
  restart: always
  volumes:
    - /volume/path/postgres:/var/lib/postgresql/data
  environment:
    - POSTGRES_USER=restyaboard
    - POSTGRES_PASSWORD=restyaboard
    - POSTGRES_DATABASE=restyaboard
elasticsearch:
  image: elasticsearch
  restart: always
  volumes:
    - /volume/path/elasticsearch:/usr/share/elasticsearch/data
```

## Default users

```
Username: admin
Password: restya

Username: user
Password: restya
```
