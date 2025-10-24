import { Router } from "express";
import db from "../db.js";

export const plan = Router();

plan.get("/me", async (req, res) => {
  const email = req.query.email as string;
  const row = await db.get("SELECT * FROM user_entitlements WHERE user_email = ?", [email]);
  res.json(row || { status: "inactive" });
});
