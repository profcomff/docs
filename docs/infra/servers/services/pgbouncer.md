# Настройка PGBouncer

PGBouncer - ПО, управляющее пулом соединений PostgreSQL.

Бэкенды, сервисы статистики генерируют по несколько подключений в БД PostgreSQL. Например, на каждый процесс связки FastAPI и SQLAlchemy может создаваться по 20 подключений. Если масштабировать это число на количество процессов, в которых запущен бэкенд и на количество бэкендов - получится довольно много подключений. Более того, некоторые сервисы оставляют соединения не закрытыми, что приводит к их утечке.

Таким образом, следить за соединениями надо на стороне базы данных.

Опытным путем было выяснено, что хуже всего ведет себя любое ПО для работы с данными - например, DataLens и Airflow.

Именно их в первую очередь стоит подключать через PGBouncer.

PGBouncer стоит между пользователем и PostgreSQL.

## Настройка
1. Запускается в паре с PostgreSQL
```yaml
services:
  postgres:
    image: postgres:16
    restart: always
    volumes:
      - profcomff-postgres:/var/lib/postgresql/data
    ports:
      - "5432:5432"
    environment:
      POSTGRES_PASSWORD: xxx

  pgbouncer:
    image: edoburu/pgbouncer
    restart: always
    volumes:
      - ./bouncer:/etc/pgbouncer
    ports:
      - 6432:6432
    depends_on:
      - postgres

volumes:
  profcomff-postgres:
    name: profcomff-postgresql-data
    external: true
```

В папке `./bouncer`, которая подключена как вольюм должен лежать конфиг и список юзеров.


Пример файла `./bouncer/pgbouncer.ini`
```ini
################## Auto generated ##################
[databases]
db = host=localhost port=5432 dbname=postgres

[pgbouncer]
listen_addr = *
listen_port = 6432
auth_type = md5
auth_file = /etc/pgbouncer/userlist.txt
pool_mode = transaction
default_pool_size = 20
max_client_conn = 200
ignore_startup_parameters = extra_float_digits

# Log settings
admin_users = postgres
```

Пример файла `./bouncer/userlist.txt`
```txt
"admin" "password123"
"user" "password"
```

## Как перейти от использования PostgreSQL к прослойке PGBouncer

Поменять порт. В примере выше доступ к БД напрямую идет через порт 5432. В URL подключения к БД он меняется на 6432 и все.

```
postgres://{user}:{password}@{hostname}:{5432}/{database-name} ---> postgres://{user}:{password}@{hostname}:{6432}/{database-name}
```

Работа будет происходить как будто с PostgreSQL, PGBouncer себя не выдает.

## Как добавить пользователя?

Прописать в файл `./bouncer/userlist.txt` его логин и пароль, соответствующие логину и паролю в PostgreSQL.

## Как добавить базу данных в поддерживаемые PGBouncer?

Иначе он не найдет ее

В поле `[databases]` добавить строку формата
```
db1 = host=host port=5432 dbname=dbname
```

## Схема развертывания сейчас

Резвернут 1 инстанс в продовой среде

Лежит в папке `srvc__postgres_db`

## Ссылки
Хороший, небольшой [гайд](https://www.youtube.com/watch?v=W-nOdwlxmhA) про то, зачем нужен PGBouncer и как его настроить

Референс [конфигурации](https://www.pgbouncer.org/config.html) PGBouncer
