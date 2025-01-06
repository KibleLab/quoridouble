# Quoridouble-BE

This project is about the Backend of the Quoridouble application.

<br>

### How to run Local Development Mode

You can run the `build --continuous` in the background to reflect the current development:

```
./gradlew build --continuous & ./gradlew bootRun --args='--spring.profiles.active=local'
```

<br>

If you avoid working in the background, you can run it using two terminal tabs:

```
# Terminal_1
./gradlew build --continuous

# Terminal_2
./gradlew bootRun --args='--spring.profiles.active=local'
```

<br>

### How to run Development Server and Production Server Mode

You can build using the following command (Create `*.jar`):

```
./gradlew clean build
```

<br>

You can run `*.jar` with the profile you want in Java:

```
nohup java -jar "[FilePath]/[FileName]".jar --spring.profiles.active="[Profiles]" &
```

or (If you want to use `PM2`)

```
pm2 start --name quoridouble-be "java -jar "[FilePath]/[FileName]".jar --spring.profiles.active="[Profiles]""
```

<br>

### Automatically add System Environment Variables with Shell script

You can define `System Environment Variables` in this files(e.g `.envs/.env`, `.envs/.env.local`, `.envs/.env.dev`, `.envs/.env.prod`):

```

# .envs/.env.local

...

# MariaDB Local

QUORIDOUBLE_LOCAL_MARIADB_HOST = localhost
QUORIDOUBLE_LOCAL_MARIADB_PORT = 3306
QUORIDOUBLE_LOCAL_MARIADB_DATABASE = quoridouble
QUORIDOUBLE_LOCAL_MARIADB_USERNAME = "[UserName]"
QUORIDOUBLE_LOCAL_MARIADB_PASSWORD = "[PASSWORD]"

# MongoDB Local

QUORIDOUBLE_LOCAL_MONGODB_HOST = localhost
QUORIDOUBLE_LOCAL_MONGODB_PORT = 27017
QUORIDOUBLE_LOCAL_MONGODB_DATABASE = quoridouble
QUORIDOUBLE_LOCAL_MONGODB_USERNAME = "[UserName]"
QUORIDOUBLE_LOCAL_MONGODB_PASSWORD = "[PASSWORD]"

...

```

<br>

You can automatically setup and remove the above as `System Environment Variables`:

```
chmod +x ./envs.sh
./envs.sh
```

```
=============================================
     Quoridouble-BE Environment Manager
=============================================
[1] Setup Environment
[2] Remove Environment
[3] Exit
=============================================
Select an option (1-3):
```

## <br />

Copyright © 2024 KibleLab
