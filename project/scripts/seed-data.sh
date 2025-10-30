#!/bin/bash
# Seed data into FoodCart database

NAMESPACE=${1:-foodcart-dev}

echo "🌱 Seeding data into namespace: ${NAMESPACE}"

DB_POD=$(oc get pod -n ${NAMESPACE} -l service=db -o jsonpath='{.items[0].metadata.name}')

if [ -z "$DB_POD" ]; then
  echo "❌ Database pod not found. Is the database deployed?"
  exit 1
fi

echo "Creating schema and inserting sample data..."

oc exec ${DB_POD} -n ${NAMESPACE} -- psql -U foodcart -d foodcart <<EOF
CREATE TABLE IF NOT EXISTS menu_items (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100),
  price DECIMAL(10,2),
  category VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS orders (
  id SERIAL PRIMARY KEY,
  customer_name VARCHAR(100),
  items TEXT,
  total DECIMAL(10,2),
  status VARCHAR(50),
  created_at TIMESTAMP DEFAULT NOW()
);

INSERT INTO menu_items (name, price, category) VALUES
  ('Pizza Margherita', 12.99, 'main'),
  ('Cheeseburger', 9.99, 'main'),
  ('Caesar Salad', 7.99, 'appetizer'),
  ('Soda', 2.99, 'drink'),
  ('Ice Cream', 4.99, 'dessert')
ON CONFLICT DO NOTHING;

INSERT INTO orders (customer_name, items, total, status) VALUES
  ('John Doe', 'Pizza, Soda', 15.98, 'pending'),
  ('Jane Smith', 'Burger, Fries, Soda', 14.97, 'completed')
ON CONFLICT DO NOTHING;

SELECT 'Seeded ' || COUNT(*) || ' menu items' FROM menu_items;
SELECT 'Seeded ' || COUNT(*) || ' orders' FROM orders;
EOF

echo "✅ Data seeding complete"
