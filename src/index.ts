import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import bodyParser from "body-parser";
import { checkout } from "./routes/checkout.js";
import { plan } from "./routes/plan.js";
import { webhooks } from "./routes/webhooks.js";
import { products } from "./routes/products.js";
import { affiliates } from "./routes/affiliates.js";

dotenv.config();

const app = express();
app.use(cors());
app.use(bodyParser.json());
app.use("/api/checkout", checkout);
app.use("/api/plan", plan);
app.use("/api/webhooks", webhooks);
app.use("/api/products", products);
app.use("/api/affiliates", affiliates);

app.get("/", (_, res) => res.json({ name: "ConnectBot eCommerce Autopilot", version: "1.0.0" }));

const PORT = process.env.PORT || 8080;
app.listen(PORT, () => console.log(`🚀 Server running at http://localhost:${PORT}`));
