# Как работаем с вебом

Для работы с вебом мы используем __FastAPI__.

Работаем мы по стандартам REST API: <https://habr.com/ru/post/483202/>

Для каждой сущности создается свой собственный роутер, в котором минимум указывается `prefix` и `tags`. `prefix` - это то, что будет всегда стоять в начале пути для данного роутера, `tags` - для удобства чтения документации в Swagger UI. 

Роутер - это объединение ручек по признаку принадлежности к одному ресурсу.

## Интерфейс API

REST API состоит из нескольких типов ручек: GET/POST/PATCH/DELETE.
- __GET__ запрос не может иметь тело в виде json. Его __не__ стоит использовать для передачи конфиденциальных данных, т.к браузер может сохранять историю запросов и т.д. Запрос будет выглядеть так `GET /router/{id}` для конкретного ресурса и `GET /router` для всех

- __POST__ запрос уже может содержать тело в виде json. Его используют для создания ресурса. JSON передается в виде __верифицируемой__ модели `pydantic`. То есть, описывается класс с полями, которые должен содержать передаваемый json. Опять же указываются type hints и необходимость передачи того или иного поля (например `id: int | None`). Запрос будет выглядеть так: `POST /router`

- __PATCH__ запрос во многом похож на POST (не рассматриваемый здесь PUT туда же). Используется для редактирования ресурса. Во многом это просто создано для удобства, по факту можно использовать для обновления и POST запросы. Но это противоречит спецификации REST, так что мы так не делаем. Запрос будет выглядеть так: `PATCH /router/{id}`

- __DELETE__ аналогичен, используется для удаления ресурсов. Вместо него так же можно использовать другие запросы с постфиксами /delete, но так как мы работаем по REST API, мы используем этот тип запросов. Пример запроса: `DELETE /router/{id}`

__Каждый__ роутер складывается в __отдельный__ файл, потом они собираются вместе в файле `base.py` через функцию `FastAPI().include_router()`. Все роутеры лежат в директории /routes/ вместе с base.py.

Когда ручка что то возвращает, мы используем json, __верифицируемый__ Pydantic'ом. Аналогично передаче данных в запрос, описанной выше:  описывается класс с полями, которые должен содержать получаемый json. Опять же указываются type hints и необходимость содержания того или иного поля(например `id: int | None`) в ответе.

## Простое FastAPI приложение
Выгляит примерно так:
```python
from fastapi import FastAPI

app = FastAPI()


@app.get("/example")
async def root():
    return {"message": "Hello World"}
```

Здесь прописано, что надо создать само приложение, а также положить по адресу `http://<host>/example`, ручку, которая будет на любой запрос отдавать:
```json
{"message": "Hello World"}
```

Более детально каждая строка описана тут: <https://fastapi.tiangolo.com/tutorial/first-steps/>

## Где искать документацию по ручкам
После того, как вы запустили FastAPI App, по адресу `http://<host>/docs` вас будет ждать _интерактивная документация_. Из нее можно кидать запросы, смотреть ответы.

Данный шаг отмечен тут: <https://fastapi.tiangolo.com/tutorial/first-steps/#interactive-api-docs>

## Пагинация
Если запрос может возвращать __большое__ количество данных, используется пагинация: ответ от сервера в таком случае представляет из себя: `{"items": result, "limit": limit, "offset": offset, "total": result.count()}`, где `limit` - максимальный размер ответа, `offset` - смещение от первого элемента, `total` - количество подходящих записей в БД.

## Middlewares
Это функция, часть которой будет вызвана __до__ запроса, часть __после__. Таким образом, можно управлять каждым запросом, добавлять информацию про него куда нибудь, добавлять какие то поля внутрь него, оборачивать в транзакции и т.д

В `base.py` подключаются __middlewares__. Про CORS, используемый, когда фронт лежит отдельно от бэка можно почитать тут: <https://docs.profcomff.com/tvoy-ff/backend/settings.html>

Подключаемый `DBSessionMiddleware` нужен для создания сессии работы с БД прямо в FastAPI, он содержится в библиотеке [fastapi-sqlalchemy](https://pypi.org/project/FastAPI-SQLAlchemy/).

Также, можно подключать и собственные middlewares, как это делать можно посмотреть тут: <https://fastapi.tiangolo.com/tutorial/middleware/>

## Pydantic
Фреймворк для сериализации и десериализации данных.

Сериализация - это процесс преобразования сложных структур данных, таких как объекты, массивы, словари и т.д., в более простой формат, который может быть сохранен в файле или передан через сеть. Сериализация используется для сохранения состояния объектов или передачи данных между программами. Результатом сериализации может быть текстовая строка или бинарное представление, которое легко восстановить обратно в исходные данные.

Десериализация - это обратный процесс, при котором данные, ранее сериализованные, восстанавливаются в исходную сложную структуру данных. Десериализация выполняется с целью использования или анализа этих данных в программе.

Например, сериализация переводит объект класса в строку, а десериализация - наоборот.

Он тесно связан с `FastAPI`, использвуется там для указания типов входных данных.

Оссновная сущность - _модель_. Выглядит так:

```python
class ParamGet(ParamPost):
    id: int
    category_id: int
    comment: str
```

Данная модель создана для того, чтобы сериализовать и десериализовать `json` вида:
```json
{
    "id": 2, 
    "category_id": 5,
    "comment": "Hello, world!"
}
```

Если в FastAPI пришел json не этого формата, то он _автоматически_ выбросит ошибку 429 - Validation Error.

Модели могут ссылаться друг на друга, тогда получается вложенная структура json.

```python
class ParamGet(ParamPost):
    id: int
    category_id: int
    comment: str


class CategoryGet(CategoryPost):
    id: int
    params: list[ParamGet] | None = None
```

Таким образом, получается вложенная структура вида:
```json
{
    "id": 4,
    "params": [
                {
                "id": 2, 
                "category_id": 4,
                "comment": "Hello, world!"
                },
                {
                "id": 3, 
                "category_id": 4,
                "comment": "Hello, profcomff!"
                }
    ]
}
```

Также, в `pydantic` есть валидаторы данных, представляемые в виде вызываемых в момент сериализации и десериализации функций. Почитать об этом можно тут: <https://docs.pydantic.dev/latest/concepts/validators/#before-after-wrap-and-plain-validators>