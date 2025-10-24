import { Router } from "express";
export const affiliates = Router();

affiliates.get("/", (_, res) => res.json({ message: "Affiliate system placeholder" }));
