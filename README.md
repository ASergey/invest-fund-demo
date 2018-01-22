
Это демо-проект на Rails 5.1 Админка для учёта основных показателей маааленького инвестиционного фонда
Фронтенд на [Activeadmin](https://activeadmin.info/)


## Требования к ПО

+ PostgreSQL >= 9.6
+ ruby-2.4.1
+ rails 5.1.2
+ redis >= 3
+ Node.js, либо поддерживаемое гемом [execjs](https://github.com/sstephenson/execjs)

## Инструкции к развёртыванию

1. `git clone`
2. Задать параметры конфигурации в `.env` файле по примеру `.env.example`
3. Установить гемы `bundle install`
4. Выполнить `rails db:setup`. Это создаст базу данных, загрузит схему и инициализирует ее с помощью данных seed
5. Запустить задачи на построение подневных отчётов
```
    $ rake fund_report:build_balance_reports_since '2017-08-31'
    $ rake fund_report:fund_report '2017-09-01'
```

## Credentials

demo@admin.com
12345678
