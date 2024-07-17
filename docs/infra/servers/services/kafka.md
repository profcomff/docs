# Kafka

## Что это такое?
Apache Kafka — распределенная система обмена сообщениями между серверными приложениями в режиме реального времени.

__Для связи микросервисов__. Kafka — связующее звено между отдельными функциональными модулями большой системы. Например, с ее помощью можно подписать микросервис на другие компоненты для регулярного получения обновлений.

__Потоковая передача данных__. Высокая пропускная способность системы позволяет поддерживать непрерывные потоки информации. За счет грамотной маршрутизации «Кафка» не только надежно передает данные, но и позволяет производить с ними различные операции.

__Ведение журнала событий__. Kafka сохраняет данные в строго организованную структуру, в которой всегда можно отследить, когда произошло то или иное событие. Информация хранится в течение заданного промежутка времени, что можно использовать для разгрузки базы данных или медленно работающих систем логирования.


В архитектуре Kafka Apache ключевыми являются концепции:

- продюсер (producer) — приложение или процесс, генерирующий и посылающий данные (публикующий сообщение);
- потребитель (consumer) — приложение или процесс, который принимает сгенерированное продюсером сообщение;
- сообщение — пакет данных, необходимый для совершения какой-либо операции (например, авторизации, оформления покупки или подписки);
- брокер — узел (диспетчер) передачи сообщения от процесса-продюсера приложению-потребителю;
- топик (тема) — виртуальное хранилище сообщений (журнал записей) одинакового или похожего содержания, из которого приложение-потребитель извлекает необходимую ему информацию.

В упрощенном виде работа Kafka Apache выглядит следующим образом:

Приложение-продюсер создает сообщение и отправляет его на узел Kafka.
Брокер сохраняет сообщение в топике, на который подписаны приложения-потребители.
Потребитель при необходимости делает запрос в топик и получает из него нужные данные.

Каждое сообщение (event или message) в Kafka состоит из ключа, значения, таймстампа и опционального набора метаданных (так называемых хедеров).

Сообщения в Kafka организованы и хранятся в именованных топиках (Topics), каждый топик состоит из одной и более партиций (Partition), распределённых между брокерами внутри одного кластера. Подобная распределённость важна для горизонтального масштабирования кластера, так как она позволяет клиентам писать и читать сообщения с нескольких брокеров одновременно.

Когда новое сообщение добавляется в топик, на самом деле оно записывается в одну из партиций этого топика. Сообщения с одинаковыми ключами всегда записываются в одну и ту же партицию, тем самым гарантируя очередность или порядок записи и чтения.

Для гарантии сохранности данных каждая партиция в Kafka может быть реплицирована n раз, где n — replication factor. Таким образом гарантируется наличие нескольких копий сообщения, хранящихся на разных брокерах.

У нас брокер всего _один_.

### Consumer Groups

Теперь давайте перейдём к консьюмерам и рассмотрим их принципы работы в Kafka.

Каждый консьюмер Kafka обычно является частью какой-нибудь консьюмер-группы.

Каждая группа имеет уникальное название и регистрируется брокерами в кластере Kafka. Данные из одного и того же топика могут считываться множеством консьюмер-групп одновременно. Когда несколько консьюмеров читают данные из Kafka и являются членами одной и той же группы, то каждый из них получает сообщения из разных партиций топика, таким образом распределяя нагрузку.

## Юзкейс в Твой ФФ
Используется она у нас для связи Auth API и Userdata API. При логине через сторонние сервисы Auth API шлет в топик сообщение с полученными только что  по OAuth новыми данными пользователя. Userdata читает этот топик и сохраняет эти данные.

## Как запустить?

Процесс достаточно сложный. Мы используем образы confluentinc. У них есть готовые [гайды](https://docs.confluent.io/platform/current/installation/docker/config-reference.html) и примеры по запуску кластера. Kafka идет в комплекте с zookepeer - базой данных, где хранится конфигурация Kafka.

### Авторизация Kafka и Zookeeper
В папке jaas лежат conf файлы примерно следующего содержания:

1. zookeeper_jaas.conf:
    ```
    Server {
      org.apache.kafka.common.security.plain.PlainLoginModule required
      username="admin"
      password="xxx"
      user_admin="xxx";
    };
    ```

2. kafka_server.conf
    ```
    KafkaServer {
      org.apache.kafka.common.security.plain.PlainLoginModule required
      username="admin"
      password="zzz"
      user_admin="zzz";
    };

    Client {
      org.apache.kafka.common.security.plain.PlainLoginModule required
      username="admin"
      password="xxx";
    };
    ```

Сервер zookeeper определяет порядок входа в инстанс zookeeper. Клиент Kafka определяет как входить в инстанс zookeeper, сервер Kafka определяет порядок входа в инстанс Kafka.

### Настройка zookeeper
```yaml
  zookeeper:
    image: confluentinc/cp-zookeeper:latest
    hostname: com_profcomff_zookeeper
    networks:
      default:
        aliases:
          - com_profcomff_zookeeper
    volumes:
      - ./jaas:/etc/zookeeper/jaas
      - zookeeper-data:/var/lib/zookeeper/data
      - zookeeper-logs:/var/lib/zookeeper/log
    environment:
      ZOOKEEPER_CLIENT_PORT: 2181
      ZOOKEEPER_TICK_TIME: 2000
      KAFKA_OPTS: "-Djava.security.auth.login.config=/etc/zookeeper/jaas/zookeeper_jaas.conf"
    healthcheck:
      test: nc -z localhost 2181 || exit -1
      interval: 10s
      timeout: 5s
      retries: 3
```
Здесь определяется, что zookeeper будет слушать на порту 2181, файл авторизации пробрасывается из предыдущего пункта. Также подключается несколько volume'ов для логов и данных.

### Настройка Kafka
```yaml
kafka:
    image: confluentinc/cp-kafka:latest
    hostname: kafka
    depends_on:
      zookeeper:
        condition: service_healthy
    networks:
      default:
      kafka:
        aliases:
          - com_profcomff_kafka
    environment:
      KAFKA_BROKER_ID: 1
      KAFKA_ZOOKEEPER_CONNECT: 'com_profcomff_zookeeper:2181'
      KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1
      KAFKA_GROUP_INITIAL_REBALANCE_DELAY_MS: 0
      KAFKA_OPTS: "-Djava.security.auth.login.config=/etc/kafka/jaas/kafka_server.conf"
      KAFKA_LISTENERS: 'SASL_USER://com_profcomff_kafka:29092,SASL_UI://0.0.0.0:19092,PLAINTEXT_HOST://0.0.0.0:9092'
      KAFKA_ADVERTISED_LISTENERS: 'SASL_USER://com_profcomff_kafka:29092,SASL_UI://kafka:19092,PLAINTEXT_HOST://localhost:9092'
      KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: 'SASL_USER:SASL_PLAINTEXT,SASL_UI:SASL_PLAINTEXT,PLAINTEXT_HOST:PLAINTEXT'
      KAFKA_INTER_BROKER_LISTENER_NAME: 'SASL_USER'
      KAFKA_SASL_ENABLED_MECHANISMS: 'PLAIN'
      KAFKA_SASL_MECHANISM_INTER_BROKER_PROTOCOL: 'PLAIN'
      KAFKA_SECURITY_PROTOCOL: 'SASL_PLAINTEXT'
    volumes:
      - ./scripts/update_run.sh:/tmp/update_run.sh
      - ./jaas:/etc/kafka/jaas
      - kafka-data:/var/lib/kafka/data
    healthcheck:
      test: kafka-topics --bootstrap-server kafka:9092 --list
      interval: 30s
      timeout: 10s
      retries: 3
```
- `KAFKA_BROKER_ID` это просто id брокера, у нас всего один брокер.

- `KAFKA_ZOOKEEPER_CONNECT` - адрес zookeeper

- `KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR` - репликация топиков, но у нас один брокер, поэтому репликации нет.

- `KAFKA_GROUP_INITIAL_REBALANCE_DELAY_MS` - задержка перебалансировки партиций при падении консьюмера в консьюмер группе

- `KAFKA_OPTS` - строка авторизации для кафки

- `KAFKA_LISTENERS` - список URIs которые Kafka будет слушать и их протоколы

- `KAFKA_ADVERTISED_LISTENERS` - список URIs, которые будут использоваться клиентами для подключения к кластеру.

- `KAFKA_LISTENER_SECURITY_PROTOCOL_MAP` - соответствие listener и механизма подключения к кафке.

- `KAFKA_INTER_BROKER_LISTENER_NAME` - имя listener'а которое используется для взаимодействия между брокерами

- `KAFKA_SASL_ENABLED_MECHANISMS` - механизм авторизации SASL

- `KAFKA_SASL_MECHANISM_INTER_BROKER_PROTOCOL` - механизм авторизации SASL который используется для взаимодействия между брокерами

- `KAFKA_SECURITY_PROTOCOL` - протокол безопасности Kafka

Также, прокинуто несколько volume'ов для логов и данных.

### Настройка Kafka UI
Используется для просмотра сообщений и состояния брокеров. Также в нем можно создавать топики.

```yaml
kafka-ui:
    image: provectuslabs/kafka-ui:latest
    networks:
      default:
      web:
        aliases:
          - com_profcomff_kafkaui
    depends_on:
      kafka:
        condition: service_healthy
    environment:
      KAFKA_CLUSTERS_0_NAME: local
      KAFKA_CLUSTERS_0_BOOTSTRAPSERVERS: kafka:19092
      KAFKA_CLUSTERS_0_PROPERTIES_SECURITY_PROTOCOL: SASL_PLAINTEXT
      KAFKA_CLUSTERS_0_PROPERTIES_SASL_MECHANISM: PLAIN
      KAFKA_CLUSTERS_0_PROPERTIES_SASL_JAAS_CONFIG: 'org.apache.kafka.common.security.plain.PlainLoginModule required username="admin" password="zzz";'
      AUTH_TYPE: "LOGIN_FORM"
      SPRING_SECURITY_USER_NAME: login
      SPRING_SECURITY_USER_PASSWORD: password
```

Пишется, куда подключаться, какой механизм использовать, какой протокол безопасности, также задается логин и пароль из файлов в папке jaas. 

`AUTH_TYPE`, `SPRING_SECURITY_USER_NAME`, `SPRING_SECURITY_USER_PASSWORD` - переменные для входа в Kafka UI.

## Использование Kafka UI
Можно посмотреть состояние топиков, брокеров, написать тестовые сообщения, посмотреть содержание топиков, создать топик в Kafka UI.

Инстанс развернут [в продакшн окружении](https://ui.kafka.profcomff.com/auth) и [в тестовом](https://ui.kafka.test.profcomff.com/auth)

Доступ сюда можно попросить у лидов, спросите в чате, если вам нужен доступ к Kafka UI.

Статья по исользованию Kafka UI прикреплен в ссылках.

## Доступ к Kafka
Доступ к Kafka Cluster осуществляется на данный момент только из локальной сети, то есть доступ извне невозможен.

Kafka подключена к внешней docker сети, которая объединяет ее с бэкендами, которым нужен к ней доступ.

Доступ осуществляется по логину и паролю, их можно спросить у лидов или просто попросить их добавить нужный секрет в репозиторий.

## Схемы данных
Данные, посылаемые в топики должны валидироваться некоторой схемой.

Решено было использовать `pydantic` для создания таких схем данных.

Решение расположено [здесь](https://github.com/profcomff/event-schema) и это размещено в виде пакета PyPi.

При создании новых топиков для нового типа данных стоит добавить схемы, которым они должны подчиняться, в данный пакет.

## Локальный подъем Kafka
При желании потестировать работу каких то компонентов с Kafka можно воспользоваться [репозиторием для локального поднятия Kafka](https://github.com/profcomff/db-kafka)

Тут расписан готовый docker-compose, который поднимет локальный кластер без паролей, и также, поднимет Kafka UI для дебага.

## Схема развертывания сейчас

Резвернут 1 инстанс в продовой среде и 1 инстанс в тестовой среде.

Лежит в папке `srvc__kafka`

## Ссылки
[Официальный сайт с конфигурацией](https://docs.confluent.io/platform/current/installation/docker/config-reference.html)

[Статья про Kafka](https://habr.com/ru/companies/slurm/articles/550934/)

[Сайт Kafka UI](https://docs.kafka-ui.provectus.io)

[Гайд по Kafka UI](https://habr.com/ru/articles/753398/)
