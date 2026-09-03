import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import { randomUUID } from "node:crypto";
import { db } from "../db";

interface UserRow {
  id: string;
  email: string;
  password_hash: string;
  created_at: string;
}

function jwtSecret(): string {
  const secret = process.env["JWT_SECRET"];
  if (!secret) {
    throw new Error("JWT_SECRET is not configured");
  }
  return secret;
}

export class AuthError extends Error {}

export function registerUser(email: string, password: string): { id: string; email: string; token: string } {
  const existing = db.prepare("SELECT id FROM users WHERE email = ?").get(email);
  if (existing) {
    throw new AuthError("E-Mail-Adresse ist bereits registriert");
  }

  const id = randomUUID();
  const passwordHash = bcrypt.hashSync(password, 10);
  db.prepare(
    "INSERT INTO users (id, email, password_hash, created_at) VALUES (?, ?, ?, ?)",
  ).run(id, email, passwordHash, new Date().toISOString());

  return { id, email, token: signToken(id) };
}

export function loginUser(email: string, password: string): { id: string; email: string; token: string } {
  const row = db.prepare("SELECT * FROM users WHERE email = ?").get(email) as UserRow | undefined;
  if (!row || !bcrypt.compareSync(password, row.password_hash)) {
    throw new AuthError("E-Mail oder Passwort ist falsch");
  }
  return { id: row.id, email: row.email, token: signToken(row.id) };
}

export function signToken(userId: string): string {
  return jwt.sign({ sub: userId }, jwtSecret(), { expiresIn: "30d" });
}

export function verifyToken(token: string): { userId: string } {
  const payload = jwt.verify(token, jwtSecret()) as { sub: string };
  return { userId: payload.sub };
}
