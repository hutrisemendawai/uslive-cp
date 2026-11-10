export async function generateAISummary(
  title: string,
  description: string,
  chatHistory: string[]
): Promise<string> {
  const contextSnippet = chatHistory.slice(-5).join(' | ');
  return `[AI Summary] Issue "${title}": ${description.slice(0, 100)}... Recent context: ${contextSnippet || 'No prior chat.'}`;
}

export interface EmailAlertPayload {
  to: string[];
  subject: string;
  ticketId: string;
  category: string;
  summary: string;
}

export async function sendEmailAlert(payload: EmailAlertPayload): Promise<boolean> {
  console.info('[EmailService] Dispatching alert:', {
    recipients: payload.to,
    subject: payload.subject,
    ticketId: payload.ticketId,
    category: payload.category,
    summary: payload.summary,
  });
  return true;
}
