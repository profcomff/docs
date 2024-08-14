# Разработка airflow dag-ов в окружении EasyCode

1. Перед использованием проверить, есть ли доступ к EasyCode. Доcтуп можно запросить по [ссылке][get_permissions]
2. В репозитории [dwh-pipelines](https://github.com/profcomff/dwh-pipelines) нажать на ссылку EasyCode.
    Она ведет на страницу создания виртуального окружения со всеми необходимыми настройками. После создания окружения его можно будет открыть в vsCode как обычную директорию. Структура папок будет примерно такая: 
    ```bash
    ls
    \airflow.code-workspace  dwh-airflow  dwh-definitions  dwh-pipelines
    ```
    airflow при этом уже запущен, необходимо только прокинуть порт **8080** на локальный адрес [гайд как это сделать](https://code.visualstudio.com/docs/editor/port-forwarding)

3. Генерация миграций в локальной базе данных.
    В окружении, настроенном в предыдущем пункте, есть постгрес база данных, dsn подключения к ней можно вытащить из переменнных окружния:
    ```bash
    echo $DB_DSN
    ```
    Для генерации миграций:
    - Заходим в definitions 
    ```bash
    cd dwh-definitions
    ```
    - Делаем venv
    ```bash
    make venv
    ```
    - Заходим в venv 
    ```bash
    source ./venv/bin/activate
    ```
    - Апдейтим базу данных.
    ```bash
    alembic upgrade head
    ```
    В случае, если адрес базы данных почему-то не подватился автоматически, добавляем его вручную
    ```bash
    DB_DSN=postgresql+psycopg2://postgres:postgres@postgres:5432/postgres alembic upgrade head
    ```
4. Разработка и дебаг эирфлоу тасков.
    Теперь, когда база данных в актуальном состоянии, нам осталось только написать таску (dag) и протестировать
    - Таски находятся в репозитории **dwh-pipelines**, открываем его в vscode:

    ```bash
    code ~/dwh-pipelines 
    ```

    - После написания таски, заходим на http://localhost:8080/
    логин пароль admin admin

    там есть кнопка connections
    ![Кнопка connections](../_images/dwh/conn_airflow.png)

    Заходим, нам надо поправить соединение с id **postgres_dwh**

    ![edit record](../_images/dwh/edit_airflow.png)


    Меняем database на postgres, смотрим чтобы остальные настройки соединения совпадали с **$DB_DSN** и сохраняем

    - Дебаг и stderr доступны на вкладке logs в таске, для запуска есть кнопка play / trigger в левом верхнем углу


**Изменения в коде не требуют перезапуска airflow**

[get_permissions]: https://forms.yandex.ru/u/65663f2784227c1f53dd8a15/
