> **«Кто владеет информацией, тот владеет миром.»**
> *Натан Майер Ротшильд, 18 июня 1815 года*

## Инструменты
Хранилища данных состоят из двух важных элементов: базы данных и ETL инструмента. База данных, как логично предположить, хранит в себе объемы данных, а ETL инструмент (от англ. Extract, Transform, Load) – это способ управления потоками этих данных. В качестве системы управления базой данных (СУБД) мы используем Postgres, в качестве ETL инструмента – Airflow. Оба инструмента зарекомендовали себя как отличные решения интерпрайз уровня и более чем подходят для студенческих проектов по пропускной способности.

*Для доступа к инструментам в продакшне обратитесь в [чат ИТ клуба физфака](https://t.me/+eIMtCymYDepmN2Ey)*

## Среда разработки
Чтобы разрабатывать и тестировать таски лучше всего развернуть окружение у себя на компьютере. Самый простой способ развертывания среды – это получить доступ к аккаунту в дев среде базы данных и установить airflow на свой компьютер как библиотеку Python.

TODO: Гайд как устанавливать dwh-airflow у себя

## Основы
### Пользовательский интерфейс
- На первой вкладке видно графы для работы с данными. Там будут и ваши, и не ваши. Слева есть выключатель, чтоб они не запускались без вашего ведома
    <img width="1008" alt="image" src="https://user-images.githubusercontent.com/5656720/216795281-0902b63b-7ece-4c9e-8e0e-e2448ff96936.png">
- На второй вкладке карта данных. Видно процессы и в какие таблицы в БД они пишут данные. [Вот пример, как добавить процессу инпуты и аутпуты](https://github.com/profcomff/dwh-pipelines/blob/20d6b89c3cc0a7b1b968fe6e9b231d34779f537f/timetable/parse.py#L15).
    <img width="1214" alt="image" src="https://user-images.githubusercontent.com/5656720/216795358-a3294890-59db-4567-ba72-72057b6021fe.png">
- Admin -> Variables. Переменные и пароли, чтоб не писать их в коде. [Пример использования](https://github.com/profcomff/dwh-pipelines/blob/20d6b89c3cc0a7b1b968fe6e9b231d34779f537f/timetable/fetch.py#L185).
    <img width="1214" alt="image" src="https://user-images.githubusercontent.com/5656720/216795367-3648fafd-d00e-4a44-a784-41f831447a4f.png">
- Admin -> Connections. Чтобы создавать подключения к источникам данных. Идейно почти то же самое, что и переменные. Например к БД. [Пример](https://github.com/profcomff/dwh-pipelines/blob/20d6b89c3cc0a7b1b968fe6e9b231d34779f537f/timetable/fetch.py#L138).
- Docs. Это место, куда идти, если что-то непонятно. Ну и если не помогло, то в чат клуба.

### Написание ДАГов и тасков в ДАГах
В лоб ДАГ из одного таска, который выводит в консоль значение переменной
```python
import logging
from airflow.decorators import dag, task
from airflow.models import Variable

@task()
def print_task():
    my_var = str(Variable.get("VARIABLE_NAME"))
    logging.info(my_var)

@dag(
    schedule='0 */12 * * *',  # Выполнять каждые 12 часов
    tags=["infra"],  # Теги для интерфейса
    default_args={
        "owner": "infra",  # Владелец для интерфейса. Тут пишите свой аккаунт GitHub, чтоб было понятно, кому писать
    }
)
def print_dag():
    print_task()

print_dag()  # Генерация дага. Без этой строки он не появится в Интерфейсе
```

ДАГ из двух тасков: первый получает значение переменной из Airflow, а второй выводит значение в консоль
```python
import logging
from airflow.decorators import dag, task
from airflow.models import Variable

@task()
def get_task():
    return str(Variable.get("VARIABLE_NAME"))

@task()
def print_task(my_var):
    logging.info(my_var)

@dag(
    schedule='0 */12 * * *',  # Выполнять каждые 12 часов
    tags=["infra"],  # Теги для интерфейса
    default_args={
        "owner": "infra",  # Владелец для интерфейса. Тут пишите свой аккаунт GitHub, чтоб было понятно, кому писать
    }
)
def print_dag():
    res = get_task()
    print_task(res)

print_dag()  # Генерация дага. Без этой строки он не появится в Интерфейсе
```

### Использование датасетов
Допустим, у вас есть ДАГ, в котором есть таск, у которого как выход указан датасет. Ну например [такой](https://github.com/profcomff/dwh-pipelines/blob/main/union_members/fetch.py#L25). Теперь, если вы укажете как schedule массив датасетов, то даг будет активироваться не по расписанию, а когда все эти датасеты будут успешно загружены.

```python
@dag(
    schedule=[Dataset("STG_UNION_MEMBER.union_member")],  # Выполнять каждые 12 часов
    ...
)
def some_dag():
    ...
```


## Литература
[1] DMBoK – DAMA Data Management Body of Knowledge (600+ страниц структурированной информации по управлению данными)
