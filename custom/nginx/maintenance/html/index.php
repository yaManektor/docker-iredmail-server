<?php
  http_response_code(503);
  header('Retry-After: 3600');
?>
<!doctype html>
<html lang="uk">
<head>
  <meta charset="utf-8">
  <title>Технічні роботи</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">

  <style>
    :root {
      --bg: #0f172a;
      --bg-card: #020617;
      --accent: #38bdf8;
      --accent-soft: rgba(56, 189, 248, 0.15);
      --text: #e5e7eb;
      --text-muted: #9ca3af;
      --danger: #f97373;
      --border: rgba(148, 163, 184, 0.35);
      --shadow-soft: 0 18px 45px rgba(15, 23, 42, 0.8);
      --radius-xl: 22px;
    }

    * {
      box-sizing: border-box;
      margin: 0;
      padding: 0;
    }

    body {
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      background:
        radial-gradient(circle at top, #1e293b 0, transparent 60%),
        radial-gradient(circle at bottom, #020617 0, #020617 60%);
      font-family: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
      color: var(--text);
      padding: 16px;
    }

    .shell {
      position: relative;
      max-width: 520px;
      width: 100%;
    }

    .glow {
      position: absolute;
      inset: -40px;
      background:
        radial-gradient(circle at 10% 0, rgba(56, 189, 248, 0.18), transparent 55%),
        radial-gradient(circle at 90% 100%, rgba(239, 68, 68, 0.18), transparent 55%);
      filter: blur(22px);
      opacity: 0.9;
      pointer-events: none;
      z-index: -2;
    }

    .card {
      position: relative;
      background: radial-gradient(circle at top left, rgba(15,23,42,0.8), rgba(15,23,42,0.96));
      border-radius: var(--radius-xl);
      padding: 28px 26px 24px;
      border: 1px solid var(--border);
      box-shadow: var(--shadow-soft);
      backdrop-filter: blur(18px);
      overflow: hidden;
    }

    .card::before {
      content: "";
      position: absolute;
      inset: 0;
      border-radius: inherit;
      background: linear-gradient(
        135deg,
        rgba(148,163,184,0.25),
        transparent 28%,
        transparent 72%,
        rgba(56,189,248,0.25)
      );
      opacity: 0.35;
      mask-image: radial-gradient(circle at top, black 0, transparent 65%);
      pointer-events: none;
    }

    .badge-row {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 18px;
      gap: 10px;
      position: relative;
      z-index: 1;
    }

    .badge {
      display: inline-flex;
      align-items: center;
      gap: 8px;
      padding: 6px 11px;
      border-radius: 999px;
      background: rgba(15,23,42,0.9);
      border: 1px solid rgba(148,163,184,0.6);
      font-size: 11px;
      text-transform: uppercase;
      letter-spacing: .14em;
      color: var(--text-muted);
    }

    .badge-dot {
      width: 8px;
      height: 8px;
      border-radius: 999px;
      background: var(--danger);
      box-shadow: 0 0 12px rgba(248, 113, 113, 0.9);
    }

    .env-tag {
      font-size: 11px;
      text-transform: uppercase;
      letter-spacing: .14em;
      color: var(--text-muted);
      opacity: 0.8;
    }

    .icon-wrap {
      width: 52px;
      height: 52px;
      border-radius: 18px;
      background: radial-gradient(circle at 30% 0, #1e293b, #020617);
      border: 1px solid rgba(148,163,184,0.5);
      display: flex;
      align-items: center;
      justify-content: center;
      margin-bottom: 18px;
      position: relative;
      z-index: 1;
    }

    .icon-inner {
      width: 28px;
      height: 28px;
      border-radius: 12px;
      background: radial-gradient(circle at 30% 0, #38bdf8, #0f172a);
      display: flex;
      align-items: center;
      justify-content: center;
      box-shadow:
        0 0 25px rgba(56,189,248,0.7),
        0 0 60px rgba(56,189,248,0.35);
    }

    .icon-inner svg {
      width: 17px;
      height: 17px;
      stroke: white;
      stroke-width: 1.8;
      fill: none;
    }

    .title-block {
      position: relative;
      z-index: 1;
      margin-bottom: 14px;
    }

    h1 {
      font-size: 24px;
      line-height: 1.25;
      margin-bottom: 6px;
    }

    .subtitle {
      font-size: 14px;
      color: var(--text-muted);
      max-width: 34rem;
    }

    .info-block {
      position: relative;
      z-index: 1;
      margin: 18px 0 18px;
      padding: 12px 12px 11px;
      border-radius: 14px;
      background: radial-gradient(circle at top left, var(--accent-soft), rgba(15,23,42,0.96));
      border: 1px solid rgba(56,189,248,0.45);
      display: flex;
      gap: 10px;
      align-items: flex-start;
      font-size: 12px;
      color: var(--text);
    }

    .info-pill {
      min-width: 66px;
      padding: 3px 7px;
      border-radius: 999px;
      border: 1px solid rgba(56,189,248,0.6);
      font-size: 10px;
      letter-spacing: .12em;
      text-transform: uppercase;
      text-align: center;
      color: var(--accent);
      background: rgba(15,23,42,0.9);
    }

    .info-text {
      flex: 1;
    }

    .info-text strong {
      font-weight: 600;
      color: #e5e7eb;
    }

    .list {
      position: relative;
      z-index: 1;
      margin: 14px 0 18px;
      padding-left: 16px;
      font-size: 13px;
      color: var(--text-muted);
    }

    .list li {
      margin-bottom: 6px;
    }

    .list li::marker {
      color: var(--accent);
    }

    .footer-row {
      position: relative;
      z-index: 1;
      display: flex;
      justify-content: space-between;
      align-items: center;
      gap: 12px;
      margin-top: 6px;
      font-size: 11px;
      color: var(--text-muted);
    }

    .hint {
      opacity: 0.7;
    }

    .contact {
      text-align: right;
      opacity: 0.85;
    }

    .contact span {
      opacity: 0.8;
    }

    .contact a {
      color: var(--accent);
      text-decoration: none;
    }

    .contact a:hover {
      text-decoration: underline;
    }

    @media (max-width: 480px) {
      .card {
        padding: 22px 18px 18px;
        border-radius: 18px;
      }
      h1 {
        font-size: 20px;
      }
      .badge-row {
        flex-direction: column;
        align-items: flex-start;
      }
      .footer-row {
        flex-direction: column;
        align-items: flex-start;
      }
      .contact {
        text-align: left;
      }
    }
  </style>
</head>
<body>
  <div class="shell">
    <div class="glow"></div>

    <div class="card">
      <div class="badge-row">
        <div class="badge">
          <span class="badge-dot"></span>
          <span>Технічні роботи</span>
        </div>
        <div class="env-tag">Webmail service</div>
      </div>

      <div class="icon-wrap">
        <div class="icon-inner">
          <svg viewBox="0 0 30 30" aria-hidden="true" class="gear-icon">
            <path d="M26.6,12.9l-2.9-0.3c-0.2-0.7-0.5-1.4-0.8-2l1.8-2.3c0.2-0.2,0.1-0.5,0-0.7l-2.2-2.2
              c-0.2-0.2-0.5-0.2-0.7,0l-2.3,1.8c-0.6-0.4-1.3-0.6-2-0.8l-0.3-2.9C17,3.2,16.8,3,16.6,3h-3.1
              c-0.3,0-0.5,0.2-0.5,0.4l-0.3,2.9c-0.7,0.2-1.4,0.5-2,0.8L8.3,5.4c-0.2-0.2-0.5-0.1-0.7,0L5.4,7.6
              c-0.2,0.2-0.2,0.5,0,0.7l1.8,2.3c-0.4,0.6-0.6,1.3-0.8,2l-2.9,0.3C3.2,13,3,13.2,3,13.4v3.1
              c0,0.3,0.2,0.5,0.4,0.5l2.9,0.3c0.2,0.7,0.5,1.4,0.8,2l-1.8,2.3c-0.2,0.2-0.1,0.5,0,0.7l2.2,2.2
              c0.2,0.2,0.5,0.2,0.7,0l2.3-1.8c0.6,0.4,1.3,0.6,2,0.8l0.3,2.9c0,0.3,0.2,0.4,0.5,0.4h3.1
              c0.3,0,0.5-0.2,0.5-0.4l0.3-2.9c0.7-0.2,1.4-0.5,2-0.8l2.3,1.8c0.2,0.2,0.5,0.1,0.7,0l2.2-2.2
              c0.2-0.2,0.2-0.5,0-0.7l-1.8-2.3c0.4-0.6,0.6-1.3,0.8-2l2.9-0.3c0.3,0,0.4-0.2,0.4-0.5v-3.1
              C27,13.2,26.8,13,26.6,12.9z M15,19c-2.2,0-4-1.8-4-4c0-2.2,1.8-4,4-4s4,1.8,4,4C19,17.2,17.2,19,15,19z" />
          </svg>
        </div>
      </div>

      <div class="title-block">
        
        <h1>Сервіс веб-пошти тимчасово недоступний</h1>
        <p class="subtitle">
          Ми виконуємо планові технічні роботи, щоб підвищити стабільність і безпеку сервісу.
          Доступ до веб-інтерфейсу пошти наразі призупинено.
        </p>
      </div>

      <div class="info-block">
        <div class="info-pill">Статус</div>
        <div class="info-text">
          Під час технічного обслуговування доступ до поштових скриньок буде тимчасово недоступний,
          у тому числі через поштові клієнти (Thunderbird, Outlook, мобільні додатки тощо).
          Усі вхідні листи, отримані в цей період, будуть збережені та стануть доступними після відновлення роботи сервісу.
        </div>
      </div>

      <ul class="list">
        <li>Веб-інтерфейс (Roundcube) тимчасово вимкнений на час оновлення.</li>
        <li>Усі наявні листи, контакти та налаштування залишаються збереженими.</li>
        <li>Якщо виникла критична необхідність доступу — зверніться до адміністратора.</li>
      </ul>

      <div class="footer-row">
        <div class="hint">
          Після завершення робіт переспрямування на цю сторінку буде вимкнено автоматично адміністратором.
        </div>
        <div class="contact">
          <span>Підтримка:</span>
          <!-- Підстав свій email/посилання, якщо треба -->
          <br>
          <a href="mailto:infoter@duck.com">infoter@duck.com</a>
        </div>
      </div>
    </div>
  </div>
</body>
</html>
