# Чеклист хорошей документации

Мы пишем много сервисов, у нас несколько десятков различных репозиториев. Среди них есть бэкэнды на фастапи, фронты на Node.JS+Vue, библиотеки Python и TypeScript. Чтобы во всем этом разобраться, особенно новичкам, надо иметь хорошие инструкции. Эта страница позволит быстро разобраться, куда и что написать, чтобы ничего не забыть, и все лежало на своих местах.

## Wiki
Wiki – наша общая база знаний. Хранится она вот здесь: <https://github.com/profcomff/.github/wiki>.

Тут хранятся общие для многих проектов вещи. Например, описания технологий и причины их использования. Также тут должна храниться вся информация, которую нужно редко, но быстро находить; которая не помещается в закреп телеги.

Есть 4 важных направления разработки, которые мы стараемся развивать одноптипно. Документация про эти направления расположена на следующих страницах:
- Backend разработка – https://github.com/profcomff/.github/wiki/%5Bdev%5D-Backend-разработка
- Frontend разработка – https://github.com/profcomff/.github/wiki/%5Bdev%5D-Frontend-разработка
- Работа с данными – https://github.com/profcomff/.github/wiki/%5Bdev%5D-Работа-с-данными
- Разработка чат ботов – https://github.com/profcomff/.github/wiki/%5Bdev%5D-Разработка-чат-ботов

Обычно, эти страницы менять не надо. Нужно убедиться, что ваш стек технологий соответствует описанному в документации.

Что должно быть на страницы о направлении разработки?
- [ ] Общая информация о том, чем занимается направление. Простым и понятным языком. Чтобы новым людям было легко выбрать, чем они хотят заниматься.
- [ ] Набор технологий: какие языки и фраемворки используем, почему их, где они применятся еще, ссылки на документацию.
- [ ] Важные пункты про разработку. Например:
    - [ ] Как создать первый проект из шаблона.
    - [ ] Как заполнять конфигурационные файлы.
    - [ ] Как работать с подключением к базе данных (БД).
    - [ ] Code style (скорее про то, как запустить авто форматирование).
    - [ ] Naming Convention (стили названий переменных, классов и т.д.).
- [ ] Важные пункты про CI/CD (автоматизированный запуск на наших серверах). Например:
    - [ ] Коротко, что такое CI/CD.
    - [ ] Какой актуальный пайплайн.
    - [ ] Где берутся переменные и как прокидываются в CI/CD.
- [ ] Полезные ссылки и источники информации.


## README.md
Это основной файл документации проекта. В нем описывается для чего был написан этот проект, как его установить, использовать и улучшать.

Что должно быть в документации проекта:
- [ ] Раздел краткого содержания: названи, описание и мотивация создания этого репозитория. *2-3 абзаца*.
- [ ] Функционал. Маркированный список того, что делает данное приложение.
    ```markdown
    - Создание кнопок и категорий для отображения на фронте
    - Управление доступами к категориям кнопок
    ```
- [ ] Блок про разработку: краткий текст с ссылками на документацию по направлению разработки, ссылкой на CONTRIBUTING.md (читай дальше). *1-2 абзаца*
- [ ] Блок Quick Start: как запустить приложение у себя самым быстрым и понятным путем. Нумерованный список.
- [ ] Блок про использование. Особенно актуален для библиотек. Тут описываются типовые сценарии использования приложения. Кратко, но емко. Если функционал большой – основные пункты сюда, остальное в отдельный `.md` файл.
    ```markdown
    ## Создание категории кнопок
    *Необходимо иметь права services.category.create*
    1. Создать новую категорию по запросу `POST /category` с телом `{"abc": "123"}`
    2. Создать в категории новую кнопку по запросу ....
    3. *Опционально* Навесить права запросом ....
    ```
- [ ] Параметризация и плагины: какие есть настройки (маркированный список с описаниями), как они влияют на приложение. Для питона все настройки из settings.py. *Не забывать добавлять ссылку на информацию по конфигурацию в доке направления разработки*.
- [ ] Ссылки: тут ссылка на доку по направлению разработки, доку по проекту (если такая имеется, например [swagger документация](https://api.test.profcomff.com)), CONTRIBUTING.md и другие полезные ссылки.

*Hint: Оставляйте ссылки не относительными путями, а полными, тогда эту доку можно будет переиспользовать в [swagger документации](https://api.test.profcomff.com) и в PYPI/NPM репозиториях*

## CONTRIBUTING.md
Этот файл документации отвечает за документацию по развертыванию приложения для разработки и о принципах разработки. Основные принципы разработки по направлению разработки должны быть описаны в общей документации направления, тут должны быть дополнения по этой документации.

Что должно быть в документации по разработке:
- [ ] Ссылка на общую часть про разработку в направлении разработки (если применимо), особенности применения этой документации.
- [ ] Какие нужно иметь пререквизиты для запуска (нужно иметь установленный Node.js, нужно иметь доступ к БД/локальную БД) с ссылками на статьи, как это сделать. Например, "Для запуска проекта нужна локальная БД. Локальную БД можно поднять следующим способом: *ссылка на вики страницу с инструкцией*".
- [ ] Какие переменные нужно установить для запуска и как узнать значения этих переменных.

## Примеры хорошей документации
- Бесплатный принтер (терминал) – https://github.com/profcomff/print-winapp – Наш внутренний проект на C# c документацией по чеклисту
- `file.d` – https://github.com/ozontech/file.d – Проект команды Ozon Tech с потрясающей читаемой документацией по проекту