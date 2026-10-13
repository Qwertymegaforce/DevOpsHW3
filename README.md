# Домашнее задание 3

## Задание 1

Файлы:
- `monitoring/prometheus/prometheus.yml` — задание `node` с меткой `instance: vm1`;
- `monitoring/grafana/dashboard.json` — экспорт дашборда с переменной `instance` и четырьмя панелями (CPU, RAM, диск, сеть).

Запуск стенда:

```bash
cd monitoring
docker compose up -d
docker compose ps
curl -s localhost:9100/metrics | grep ^node_ | head
```

Скриншоты в папке скриншоты, названия соответствуют заданиям:

## Задание 2

Файлы: `counter-backend/Dockerfile.single`, `counter-backend/Dockerfile.multistage`, `counter-backend/Dockerfile.nonroot`, `counter-backend/.dockerignore`.

Сборка и проверка выполнялись из `counter-backend/` командой `sh check.sh 2>&1 | tee build.log`. Полный лог: [logs/build.log](logs/build.log).

Для каждого образа: сборка, запуск контейнера, `GET /api/counter`, `POST /api/counter`, повторный `GET` и `docker exec ... id`.

### counter:single (без многоступенчатой сборки, root)

```
63af4c8023481b7f7bcad27378aa0060edfafbe470ff62349e244f2585573e5d
GET
{"count": 0} [200]
POST
{"count": 1} [201]
GET
{"count": 1} [200]
id
uid=0(root) gid=0(root) groups=0(root)
c-single
```

### counter:multistage (многоступенчатая сборка, root)

```
f54fe81389f94905cbbc6958219ff277046541cc5b13a9391f2d44fd88d92263
GET
{"count": 0} [200]
POST
{"count": 1} [201]
GET
{"count": 1} [200]
id
uid=0(root) gid=0(root) groups=0(root)
c-multistage
```

### counter:nonroot (многоступенчатая сборка, не root)

```
fc38cb9c3ae7b5820b872e05057b63997e0420190e07f22f7911d0e4a57afced
GET
{"count": 0} [200]
POST
{"count": 1} [201]
GET
{"count": 1} [200]
id
uid=10001(app) gid=10001(app) groups=10001(app)
c-nonroot
```

### Сравнение размеров образов

```
TAG          SIZE
nonroot      234MB
multistage   234MB
single       380MB
```

`multistage` меньше `single` на 146 МБ: в финальный образ не попадают Poetry, инструменты сборки и исходники, копируется только `dist`. Размеры `multistage` и `nonroot` совпадают с точностью до мегабайта: `nonroot` добавляет лишь запись пользователя в `/etc/passwd` и `/etc/group`, а `USER` — метаданные образа.