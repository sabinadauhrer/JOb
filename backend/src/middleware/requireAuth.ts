import type { NextFunction, Request, Response } from "express";
import { verifyToken } from "../services/authService";

declare global {
  // eslint-disable-next-line @typescript-eslint/no-namespace
  namespace Express {
    interface Request {
      userId?: string;
    }
  }
}

export function requireAuth(req: Request, res: Response, next: NextFunction): void {
  const header = req.headers.authorization;
  if (!header?.startsWith("Bearer ")) {
    res.status(401).json({ error: "Anmeldung erforderlich" });
    return;
  }

  try {
    const { userId } = verifyToken(header.slice("Bearer ".length));
    req.userId = userId;
    next();
  } catch {
    res.status(401).json({ error: "Sitzung ungültig oder abgelaufen" });
  }
}
