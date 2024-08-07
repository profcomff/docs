# Серверное администрирование

## О чем это?
О том, как устроена серверная инфраструктура Твой ФФ, какие в ней есть сервисы, окружения, какие проблемы могут возникнуть, как с ними бороться. Также, наиболее часто встречающиеся задачи, как их решать.

## Окружения
В данный момент приложение Твой ФФ развернуто на двух серверах. На одном из серверов запущена тестовая среда, на другом - продовая. Сервера находятся в разных ДЦ у разных хостеров. Зайти и на тот и на другой сервер можно по ssh, доступы можно спросить у лидов. Два окружения понадобилось по причине того, что один сервер перестал справлятся с нагрузкой двух окружений. Два сервера во многом подобны друг другу: структура папок, развернутые сервисы, базы данных. В таком ключе и предлагается их развивать в дальнейшшем.

В обоих окружениях нельзя вводить необдуманные команды, это может привести к необратимым потерям данных. Также, нельзя пускать на сервер сторонних людей не из команды, а доступ в команде должен быть только у самых опытных ее членов.

## Список сервисов
В тестовой и продовой среде на данный момент развернуты:
1. PostgreSQL - база данных
2. Content Delivery Network - сеть доставки контанта, в нашем случае просто папочка с контентом, доступная в интернете
3. Caddy WebProxy -  reverse proxy для HTTP/HTTPS трафика
4. Kafka Cluster - брокер сообщений
5. mailu - почтовый сервер
6. file.d - Сборщик логов
7. Coder - система для поднятия разработческой среды прямо из браузера
8. Swagger UI - OpenAPI документация по путям наших бэкендов

Возможны, некоторые отличия, но они несущественны

## Если хочется развернуть что-то новое
Обязательно подумайте, точно ли оно вам надо, оцените сложность новой технологии, как ее будут осваивать люди без опыта, можно ли это реализовать на имеющихся сервисах. Оцените, сколько времени уйдет на настройку всего. Стоит ли вводить новые технологии - решать должен человек с опытом работы, самостоятельно принимать такие решения не стоит.

## Тестовая среда
Если хочется поэкспериментировать с чем то новым и неизвестным, стоит разворачивать это в тестовой среде. Также, если потенциально новый сервис может  требовать очень производительного железа, лучше тоже разворачивать это в тестовом окружении, так продовый сервер не будет загружен в самый неподходящий момент.

## Продовая среда
Тут мы стараемся держать только продовые инстаны сервисов. Сюда не стоит деплоить ничего такого, что может съесть 100проц процессора, например, тут не стоит учить нейронки.

## Как разворачивать сервисы
1. Оценить сколько сервис требует железа, если это несколько jvm, то стоит подумать, прежде чем запускать.
2. Разворачивать сервисы __только__ в docker контейнерах. Нельзя разворачивать сервисы в основной ОС, это ее загрязняет и делает администрирование сложнее.
3. Старатьтся не открывать порты наружу. Должен быть открыт в идеале только 80 и 443 порты, но бывают и исключения.
