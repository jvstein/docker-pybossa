# PyBossa Docker container
Docker container for running PyBossa.

# Quick Start
This assumes that you've got an external database already set up and
initialized. Modify the POSTGRES_URL variable accordingly. If you haven't done
that yet, see the [Initialize Database](#initialize-database) section below.

0. (One-time) Set up a PostgreSQL database according to the [Pybossa install docs][db] or follow the instructions in the [Run PostgreSQL in Docker](#run-postgresql-in-docker) section.
0. (One-time) Create the PyBossa tables in your database.
    ```
    docker run --rm -it \
      -e POSTGRES_URL="postgresql://pybossa:supersecretpassword@db/pybossa" \
      jvstein/pybossa \
      python cli.py db_create
    ```
0. Start the Redis master.
    ```
    docker run -d --name redis-master redis:3.0-alpine
    ```

0. Start Redis Sentinel.
    ```
    docker run -d --name redis-sentinel \
      --link redis-master \
      jvstein/redis-sentinel
    ```

0. Start the PyBossa background worker.
    ```
    docker run -d --name pb-worker \
      --link redis-master \
      --link redis-sentinel \
      -e POSTGRES_URL="postgresql://pybossa:supersecretpassword@db/pybossa" \
      jvstein/pybossa \
      python app_context_rqworker.py scheduled_jobs super high medium low email maintenance
    ```

0. Start the PyBossa frontend.
    ```
    docker run -d --name pybossa \
      --link redis-master \
      --link redis-sentinel \
      -e POSTGRES_URL="postgresql://pybossa:supersecretpassword@db/pybossa" \
      -p 8080:8080 \
      jvstein/pybossa
    ```

## Run PostgreSQL in Docker
I don't recommend running your database in Docker unless you've fully considered
the consequences and know how to ensure your data is preserved. However, for
*simple test purposes*, this is adequate.

0. Start PostgreSQL in a container. Change `/tmp/postgres` to a more permanent
   volume path if you need your data to persist across docker container
   instances.
    ```
    docker run -d --name pybossa-db \
        -e POSTGRES_USER=pybossa \
        -e POSTGRES_PASSWORD=supersecretpassword \
        -e PGDATA=/data/pgdata \
        -v /tmp/postgres:/data \
        postgres:9.6-alpine
    ```

0. Add `--link pybossa-db:db` to the background and frontend pybossa commands
   above to link to your database.

[db]: http://docs.pybossa.com/en/latest/install.html#configuring-the-databasest/install.html
