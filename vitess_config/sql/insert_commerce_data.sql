insert into customer(email) values('alice@domain.com');
insert into customer(email) values('bob@domain.com');
insert into customer(email) values('charlie@domain.com');
insert into customer(email) values('dan@domain.com');
insert into customer(email) values('eve@domain.com');
insert into product(sku, description, price) values('SKU-1001', 'Monitor', 100);
insert into product(sku, description, price) values('SKU-1002', 'Keyboard', 30);
insert into corder(customer_id, sku, price) values(1, 'SKU-1001', 100);
insert into corder(customer_id, sku, price) values(2, 'SKU-1002', 30);
insert into corder(customer_id, sku, price) values(3, 'SKU-1002', 30);
insert into corder(customer_id, sku, price) values(4, 'SKU-1002', 30);
insert into corder(customer_id, sku, price) values(5, 'SKU-1002', 30);