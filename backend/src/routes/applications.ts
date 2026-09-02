import { Router } from "express";
import nodemailer from "nodemailer";
import { z } from "zod";

export const applicationsRouter = Router();

const sendRequestSchema = z.object({
  to: z.string().email(),
  subject: z.string().min(1),
  body: z.string().min(1),
  cvPdfBase64: z.string().min(1),
  cvFileName: z.string().optional(),
});

applicationsRouter.post("/send", async (req, res) => {
  const parsed = sendRequestSchema.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ error: "invalid request body", details: parsed.error.flatten() });
    return;
  }

  const { SMTP_HOST, SMTP_PORT, SMTP_USER, SMTP_PASS, SMTP_FROM } = process.env;
  if (!SMTP_HOST || !SMTP_USER || !SMTP_PASS || !SMTP_FROM) {
    res.status(503).json({ error: "E-Mail-Versand ist nicht konfiguriert (SMTP_* fehlt)" });
    return;
  }

  const { to, subject, body, cvPdfBase64, cvFileName } = parsed.data;
  const transporter = nodemailer.createTransport({
    host: SMTP_HOST,
    port: SMTP_PORT ? Number(SMTP_PORT) : 587,
    secure: SMTP_PORT === "465",
    auth: { user: SMTP_USER, pass: SMTP_PASS },
  });

  try {
    await transporter.sendMail({
      from: SMTP_FROM,
      to,
      subject,
      text: body,
      attachments: [
        {
          filename: cvFileName ?? "Lebenslauf.pdf",
          content: Buffer.from(cvPdfBase64.replace(/\s+/g, ""), "base64"),
          contentType: "application/pdf",
        },
      ],
    });
    res.json({ status: "sent" });
  } catch (err) {
    res.status(502).json({ error: err instanceof Error ? err.message : "E-Mail-Versand fehlgeschlagen" });
  }
});
