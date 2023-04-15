#!/bin/bash

(
    docker exec postgres psql -U postgres -c """
    CREATE TABLE inventory.another_products (
        id serial4 NOT NULL,
        "name" varchar(255) NOT NULL,
        description varchar(512) NULL,
        weight float8 NULL,
        CONSTRAINT another_products_pkey PRIMARY KEY (id)
    );
    """ && \
    echo "Database ``inventory.another_products`` created."
) && (
    docker exec postgres psql -U postgres -c """
    INSERT INTO inventory.another_products ("name",description,weight)
        select md5(random()::text) as "name",
        md5(random()::text) as description,
        floor(random()*1000000) as weight
        from generate_Series(0,100000 - 1) id;
    COMMIT;
    """ && \
    echo "Inserted 100000 records in ``inventory.another_products`` created."
) && (
    docker exec postgres psql -U postgres -c """
    INSERT INTO inventory.products ("name",description,weight)
        select md5(random()::text) as "name",
        md5(random()::text) as description,
        floor(random()*1000000) as weight
        from generate_Series(0,1 - 1) id;
    """ && \
    echo "Inserted 1 records in ``inventory.products`` created."
) && (
    echo "Wait 10 seconds for debezium consume replication slot."
    sleep 10
) && (
    echo "Check ``inventory.another_products`` that the table is populated:"
) && (
    curl --request PUT \
    --url http://localhost:8083/connectors/inventory-connector/config \
    --header 'Content-Type: application/json' \
    --data '{
        "connector.class": "io.debezium.connector.postgresql.PostgresConnector",
        "tasks.max": "1",
        "database.hostname": "postgres",
        "database.port": "5432",
        "database.user": "postgres",
        "database.password": "postgres",
        "database.dbname": "postgres",
        "database.server.name": "dbserver1",
        "table.whitelist": "inventory.another_products,inventory.new_products,inventory.customers,inventory.geom,inventory.orders,inventory.products,inventory.products_on_hand,inventory.spatial_ref_sys,dba.dbz_signal",
        "tombstones.on.delete": "false",
        "snapshot.mode": "initial",
        "slot.name": "inventory",
        "signal.data.collection": "dba.dbz_signal"
    }'
) && (
    docker exec postgres psql -U postgres -c """
    INSERT INTO dba.dbz_signal VALUES ('signal-2', 'execute-snapshot', '{\"data-collections\": [\"inventory.another_products\"]}');
    """ && \
    echo "Send signal to snapshot ``inventory.another_products`` created."
) && (
    echo "Wait 10 seconds for snapshot to complete."
    sleep 10
) && (
    docker exec postgres psql -U postgres -c """
    INSERT INTO inventory.another_products ("name",description,weight)
        select md5(random()::text) as "name",
        md5(random()::text) as description,
        floor(random()*1000000) as weight
        from generate_Series(0,2 - 1) id;
    """ && \
    echo "Inserted 2 records in ``inventory.another_products`` created."
) && (
    echo "Check in ``inventory.another_products`` that have 100000 ``r`` records and 2 ``c``."
)