#!/bin/bash
(
    docker exec postgres psql -U postgres -c """
    CREATE TABLE inventory.new_products (
        id serial4 NOT NULL,
        "name" varchar(255) NOT NULL,
        description varchar(512) NULL,
        weight float8 NULL,
        CONSTRAINT new_products_pkey PRIMARY KEY (id)
    );
    """ && \
    echo "Database ``inventory.new_products`` created."
) && (
    docker exec postgres psql -U postgres -c """
    INSERT INTO inventory.new_products ("name",description,weight)
        select md5(random()::text) as "name",
        md5(random()::text) as description,
        floor(random()*1000000) as weight
        from generate_Series(0,100000 - 1) id;
    COMMIT;
    """ && \
    echo "Inserted 100000 records in ``inventory.new_products`` created."
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
    echo "Check ``inventory.new_products`` that the table is populated:"
)
