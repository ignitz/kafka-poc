#!/bin/bash

(
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
        "table.whitelist": "inventory.new_products,inventory.customers,inventory.geom,inventory.orders,inventory.products,inventory.products_on_hand,inventory.spatial_ref_sys,dba.dbz_signal",
        "tombstones.on.delete": "false",
        "snapshot.mode": "initial",
        "slot.name": "inventory",
        "signal.data.collection": "dba.dbz_signal"
    }'
) && (
    docker exec postgres psql -U postgres -c """
    INSERT INTO dba.dbz_signal VALUES ('signal-1', 'execute-snapshot', '{\"data-collections\": [\"inventory.new_products\"]}');
    """ && \
    echo "Send signal to snapshot ``inventory.new_products`` created."
) && (
    echo "Wait 10 seconds for snapshot to complete."
    sleep 10
) && (
    docker exec postgres psql -U postgres -c """
    INSERT INTO inventory.new_products ("name",description,weight)
        select md5(random()::text) as "name",
        md5(random()::text) as description,
        floor(random()*1000000) as weight
        from generate_Series(0,1 - 1) id;
    """ && \
    echo "Inserted 1 records in ``inventory.new_products`` created."
) && (
    echo "Check in ``inventory.new_products`` that have 100000 ``r`` records and 1 ``c``."
)