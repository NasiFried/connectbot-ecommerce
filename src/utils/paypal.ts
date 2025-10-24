import axios from "axios";
import dotenv from "dotenv";
dotenv.config();

const { PAYPAL_CLIENT_ID, PAYPAL_CLIENT_SECRET, PAYPAL_MODE } = process.env;
const API_BASE = PAYPAL_MODE === "live"
  ? "https://api-m.paypal.com"
  : "https://api-m.sandbox.paypal.com";

async function getAccessToken() {
  const res = await axios.post(
    `${API_BASE}/v1/oauth2/token`,
    "grant_type=client_credentials",
    {
      auth: { username: PAYPAL_CLIENT_ID!, password: PAYPAL_CLIENT_SECRET! },
      headers: { "Content-Type": "application/x-www-form-urlencoded" },
    }
  );
  return res.data.access_token;
}

export async function createOrder(price: number, currency = "USD") {
  const token = await getAccessToken();
  const res = await axios.post(
    `${API_BASE}/v2/checkout/orders`,
    {
      intent: "CAPTURE",
      purchase_units: [{ amount: { currency_code: currency, value: price } }],
    },
    { headers: { Authorization: `Bearer ${token}` } }
  );
  return res.data;
}
