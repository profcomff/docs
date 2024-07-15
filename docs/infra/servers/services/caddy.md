# Caddy

## Что это такое?
Caddy представляет собой обратный прокси-сервер (обратный прокси-сервер).

Caddy поддерживает HTTP/2, HTTP и HTTPS, позволяет автоматически получать и обновлять сертификаты Let's Encrypt. Обладает кроссплатформенностью: можно установить на любую ОС, а также поддерживает разные архитектуры процессоров. Также Caddy можно использовать просто в Docker-контейнере.

Основные особенности Caddy:

1. Самая простая и понятная настройка, легко читается и пишется конфигурационный файл, минималистичность.
2. Автоматическое получение и обновление SSL-сертификатов.
3. Использует HTTPS по умолчанию.

## Как работает?
Откуда нибудь приходит запрос. Обычно это происходит после резолва доменного имени в ip адрес сервера, на котором стоит caddy.

Запрос идет по протоколу http или https и приходит на порты 80 или 443 соответственно.

Эти порты сслушает caddy. У него есть доступ к данным запроса, например, куда этот запрос бьл изначально направлен: какое доменное имя, какой идентификатор ресурса, какой метод. На основании этого он может принимать решение, куда перенаправить запрос. Перенаправляет он, в основном, на контейнеры внутри сервера, поэтому называется _reverse_ прокси.

Caddy находится в одной docker network совсеми контейнерами. Таким образом он может перенаправлять запрос напрямую в контейнер, у контейнера не надо открывать никакие порты.

## Как добавить записи?
### Новый микросервис
Запуск производится в Docker контейнере. Рядом с caddy лежит Makefile с возможностьсю провести запуск и рестарт.

Для начала надо разобраться как создать DNS запись, для этого написана отдельная статья.
Предположим, мы создали запись типа A для нового микросервиса.

Мы идем в `Caddyfile` и ищем место
```
api.profcomff.com:443 {
    route /marketing/* {
        reverse_proxy com_profcomff_api_marketing:80
    }
    ...
}
```

и добавляем сюда новый такой же `route`, отправлять он будет в новый контейнер

```
api.profcomff.com:443 {
    route /marketing/* {
        reverse_proxy com_profcomff_api_marketing:80
    }
    route /new/* {
        reverse_proxy com_profcomff_api_new:80
    }
    ...
}
```
Перезагружаем Caddy, смотрим результат.

### Редирект
```
some.com {
    redir https://www.some.com{uri} permanent
}
```

здесь прописано, что все запросы, пришедшие на `some.com` всегда перенаправляются на `https://www.some.com` и туда прикрепляется адрес ресура в конец.

### CORS
Что такое CORS можно почитать [тут](https://habr.com/ru/companies/macloud/articles/553826/)

Нужные заголовки выглядят так:
```
(FRONTEND_CORS_HEADERS) {
    header Access-Control-Allow-Origin *
    header Access-Control-Allow-Credentials true
    header Access-Control-Allow-Methods GET
    header Access-Control-Allow-Headers Authorization,DNT,X-CustomHeader,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,X-Accept-Charset,X-Accept,origin,accept,if-match,destination,overwrite
}
```

Их надо импортировать туда, где они нужны:
```
https://vu.profcomff.com {
    import FRONTEND_CORS_HEADERS
    reverse_proxy com_profcomff_vu:80
}
```

## Образец docker compose
```yaml
version: '3.6'

services:
  web-proxy:
    image: caddy
    restart: always
    ports:
      - 80:80    # http
      - 443:443  # https
    networks:
      - internal-net
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile
      # Prevent untagged volumes
      - ./data/coreconfig:/config
      - ./data/coredata:/data
networks:
  internal-net:
    external: true
    name: web
```

## Swagger UI
Деплоится вместе с caddy, представляет собой сборник и UI для файлов формата openapi.json

В `docker-compose.yaml` есть запись для этого сервиса:
```yaml
swagger-ui:
    image: swaggerapi/swagger-ui:v5.17.4
    networks:
      internal-net:
        aliases:
          - com_profcomff_api
    environment:
      - |
        URLS=[
          { url: 'https://api.profcomff.com/auth/openapi.json', name: 'auth' }
        ]
```

При необходимости добавить спецификацию OpenAPI надо добавить подобную строку в переменную `URLS`.


## Схема развертывания сейчас

Резвернут 1 инстанс в продовой среде и 1 в тестовой

Лежит в папке `srvc__caddy_webproxy`.

## Ссылки

[Туториал по Caddyfile](https://caddyserver.com/docs/caddyfile-tutorial)