import sqlite3 from "sqlite3";
import { open } from "sqlite";

export const db = await open({
  filename: "./connectbot.sqlite",
  driver: sqlite3.Database,
});

await db.exec(`
  CREATE TABLE IF NOT EXISTS user_entitlements (
    user_email TEXT PRIMARY KEY,
    plan TEXT,
    billing_cycle TEXT,
    status TEXT DEFAULT 'inactive',
    features TEXT,
    updated_at TEXT DEFAULT CURRENT_TIMESTAMP
  );
  CREATE TABLE IF NOT EXISTS products (
    id TEXT PRIMARY KEY,
    name TEXT,
    price REAL,
    currency TEXT,
    stock INTEGER
  );
`);
