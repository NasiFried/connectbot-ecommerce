import { Router } from "express";
export const webhooks = Router();

webhooks.post("/", async (req, res) => {
  console.log("Webhook event:", req.body.event_type);
  res.sendStatus(200);
});
