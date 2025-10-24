import { Router } from "express";
import db from "../db.js";
import { v4 as uuidv4 } from "uuid";

export const products = Router();

products.get("/", async (_, res) => {
  const items = await db.all("SELECT * FROM products");
  res.json(items);
});

products.post("/", async (req, res) => {
  const { name, price, stock, currency } = req.body;
  const id = uuidv4();
  await db.run(
    "INSERT INTO products (id, name, price, currency, stock) VALUES (?,?,?,?,?)",
    [id, name, price, currency, stock]
  );
  res.json({ success: true, id });
});
