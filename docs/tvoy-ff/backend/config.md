# Как работаем с конфигом

Для конфигурации мы используем переменные окружения. Чтобы многократно не заполнять них, мы используем файлы окружения. Для работы с файлами окружения мы используем ``pydantic-settings``. В файле settings.py создается класс Settings, наследник BaseSettings, в котором определятся, что должно быть в .env файле. Здесь и везде далее используются type hints. Сам python не строго относится к их соблюдения, только подсказывает вам в IDE, что вы должны передать в качестве аргументов куда-либо, где указаны типы. Однако Pydantic проверяет соответствие указанных типов и полученных данных, что очень удобно и безопасно.
https://fastapi.tiangolo.com/advanced/settings/#pydantic-settings

Локально создается `.env` файл в корне проекта.
```bash
touch .env
```

То есть, он будет виден в рабочем каталоге как `.env`, а не как `../.env` и прочие вариации путей до него. То есть в файле `settings.py` прописывается что то такое:
```python
from pydantic import ConfigDict, PostgresDsn
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    """Application settings"""

    DB_DSN: PostgresDsn = 'postgresql://postgres@localhost:5432/postgres'
    model_config = ConfigDict(case_sensitive=True, env_file=".env", extra="allow")
```

Пример .env файла, например, из бэкенда расписания: https://github.com/profcomff/timetable-backend/blob/main/.env.example.
Когда вы первый раз отправляете коммит, проверяйте наличие файла `.gitignore`, `.env` файл не должен попасть в изменения.
