# Выкатываем новый бэкэнд на прод
Чтобы новый сервис появился в тесте и проде нужно сделать несколько важных вещей:

1. Подготовить БД (это надо повторить и в тестовой БД, и в продовой)
    1. Создать новых пользователей в тестовой и продовой базах данных: `CREATE USER srvc_test_marketing_api IN GROUP group_service_test PASSWORD '...';`
    2. Создать новые схемы для хранения таблиц: `create schema api_marketing authorization srvc_test_marketing_api;`
    3. Назначить для пользователя схему по умолчанию: `alter user srvc_test_marketing_api set search_path to api_marketing;`
2. Настройка репозитория
    1. Создать среды исполнения (Environments) для теста и прода (обычно во всех репозиториях Testing и Production)
    2. В средах создать переменные с ключами, необходимые для запуска сервиса. Например данные для подключения к БД мы кладем в переменную `DB_DSN`: <br/> <img width="864" alt="image" src="https://user-images.githubusercontent.com/5656720/192113572-cf417d78-1868-4f36-99d9-14d2b67fa0a2.png"> <br/> *На изображении 2 ключа, к которым можно [обратиться из CI через](https://github.com/profcomff/marketing-backend/blob/main/.github/workflows/build_and_publish.yml#L115) `{{ secrets.НАЗВАНИЕ }}`*
    3. На прод настроить ревьюера, который сможет выкатывать сервис для всех пользователей.
3. Упаковать проект для запуска в Docker
    1. Создать `Dockerfile` в корне проекта. [Пример докерфайла](https://github.com/profcomff/marketing-backend/blob/main/Dockerfile)
4. Настроить GitHub Actions для автоматического запуска сборки и запуска на сервере
    1. Создать папку `.github/workflows`
    2. Положить в него файлики для раскатки теста, прода, тестирования и т.д.
    3. В качестве шаблона можно использовать [этот пример](https://github.com/profcomff/marketing-backend/blob/main/.github/workflows/build_and_publish.yml). Тут происходит раскатка в тест при коммитах в ветку `main` и раскатка в прод при создании тегов.
5. Настроить сервер
    1. Сервисы находятся в отдельных докер контейнерах, их видно только во внутренней сети
    2. У нас есть Caddy (это [reverse proxy](https://ru.wikipedia.org/wiki/%D0%9E%D0%B1%D1%80%D0%B0%D1%82%D0%BD%D1%8B%D0%B9_%D0%BF%D1%80%D0%BE%D0%BA%D1%81%D0%B8) [http сервер](https://ru.wikipedia.org/wiki/%D0%92%D0%B5%D0%B1-%D1%81%D0%B5%D1%80%D0%B2%D0%B5%D1%80)), который запросы из внешней сети прокидывает во внутреннюю. В него надо добавить новую запись [reverse_proxy](https://caddyserver.com/docs/caddyfile/directives/reverse_proxy).

    Пример Caddy записи
    ```
    printer.api.profcomff.com:443 {
        reverse_proxy com_profcomff_api_printer:80
    }
    ```
    3. Понять, что по ссылкам в прошлом пункте ничего не понятно и просто скопировать готовую конфигурацию соседнего сервиса :)
