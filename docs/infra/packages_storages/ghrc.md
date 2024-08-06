# Github Docker Registry

## Что это такое
Хранилка для Docker образов.

Реестр контейнеров хранит образы в организации и позволяет связать образ с репозиторием. Вы можете выбрать, наследовать ли разрешения от репозитория или устанавливать детальные разрешения независимо от репозитория. Вы также можете анонимно получить доступ к общедоступным образам контейнеров.

## Аутентификация
Происходит автоматиччески в CI/CD, вот пример: <https://github.com/profcomff/auth-api/blob/484047d57b8c2bc3510f35d6ef773df349fc0018/.github/workflows/build_and_publish.yml#L26>

- `${{ secrets.GITHUB_TOKEN }}` - это дефолтный токен организации, его генерирует сам GitHub, искать его не надо
- `${{ github.actor }}` - тоже дефлотная переменная
- `${{ env.REGISTRY }}` - адрес registry, задается сверху каждого yaml файла GitHub Actions

## Ссылки
[Статья с использованием ghrc](https://habr.com/ru/articles/824526/)

[Официальная документация](https://docs.github.com/ru/packages/working-with-a-github-packages-registry/working-with-the-container-registry)