import { Router } from "express";
import { createOrder } from "../utils/paypal.js";
export const checkout = Router();

checkout.post("/create", async (req, res) => {
  const { price, currency } = req.body;
  try {
    const order = await createOrder(price, currency);
    res.json(order);
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});
