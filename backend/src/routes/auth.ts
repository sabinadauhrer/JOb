import { Router } from "express";
import { AuthError, loginUser, registerUser } from "../services/authService";
import { loginRequestSchema, registerRequestSchema } from "../schemas/auth";
import { requireAuth } from "../middleware/requireAuth";
import { db } from "../db";

export const authRouter = Router();

authRouter.post("/register", (req, res) => {
  const parsed = registerRequestSchema.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ error: "invalid request body", details: parsed.error.flatten() });
    return;
  }

  try {
    const { id, email, token } = registerUser(parsed.data.email, parsed.data.password);
    res.status(201).json({ id, email, token });
  } catch (err) {
    if (err instanceof AuthError) {
      res.status(409).json({ error: err.message });
      return;
    }
    res.status(500).json({ error: "Registrierung fehlgeschlagen" });
  }
});

authRouter.post("/login", (req, res) => {
  const parsed = loginRequestSchema.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ error: "invalid request body", details: parsed.error.flatten() });
    return;
  }

  try {
    const { id, email, token } = loginUser(parsed.data.email, parsed.data.password);
    res.json({ id, email, token });
  } catch (err) {
    if (err instanceof AuthError) {
      res.status(401).json({ error: err.message });
      return;
    }
    res.status(500).json({ error: "Login fehlgeschlagen" });
  }
});

authRouter.get("/me", requireAuth, (req, res) => {
  const row = db.prepare("SELECT id, email FROM users WHERE id = ?").get(req.userId);
  if (!row) {
    res.status(404).json({ error: "Nutzer nicht gefunden" });
    return;
  }
  res.json(row);
});
