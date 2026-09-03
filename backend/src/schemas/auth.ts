import { z } from "zod";

export const registerRequestSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8, "Passwort muss mindestens 8 Zeichen haben"),
});

export const loginRequestSchema = z.object({
  email: z.string().email(),
  password: z.string().min(1),
});

export type RegisterRequest = z.infer<typeof registerRequestSchema>;
export type LoginRequest = z.infer<typeof loginRequestSchema>;
