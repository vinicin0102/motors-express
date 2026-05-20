# 🚗 Driver AI — Copiloto Inteligente para Motoristas de App

<p align="center">
  <strong>Analise corridas em tempo real. Saiba instantaneamente se compensa.</strong>
</p>

---

## 📋 Visão Geral

**Driver AI** é um aplicativo completo para motoristas de **Uber, 99 e InDrive** que funciona como um copiloto inteligente, analisando corridas em tempo real e informando automaticamente se a corrida compensa financeiramente.

### ✨ Principais funcionalidades

- 🔍 **Detecção automática** de corridas via Accessibility Service
- 📊 **Análise inteligente** de valor/km, lucro e custo
- 🎯 **Overlay flutuante** que aparece sobre os apps de transporte
- 📈 **Dashboard premium** com estatísticas e gráficos
- 🤖 **IA de estratégia** com insights personalizados
- 💎 **Sistema de assinaturas** (FREE / PRO / PREMIUM)
- 🔔 **Notificações inteligentes** de metas e dicas
- 🛡️ **Painel administrativo** completo

---

## 🏗️ Arquitetura

```
driver-ai/
├── mobile/              # Flutter App (Clean Architecture)
│   ├── lib/
│   │   ├── core/        # Theme, constants, utils, router
│   │   └── features/    # Auth, Dashboard, Rides, Goals, etc.
│   └── android/         # Native Kotlin (Overlay + Accessibility)
│
├── backend/             # Node.js API
│   ├── src/
│   │   ├── routes/      # API endpoints
│   │   ├── middleware/   # Auth, plan check, rate limit
│   │   └── utils/       # Logger, helpers
│   └── prisma/          # Database schema + seeds
│
├── admin-panel/         # Web Admin Dashboard
│   ├── css/
│   ├── js/
│   └── index.html
│
└── README.md
```

---

## 🛠️ Stack Tecnológica

| Camada | Tecnologia |
|--------|-----------|
| **Mobile** | Flutter 3.x + Riverpod + Material Design 3 |
| **Backend** | Node.js + Express + Prisma ORM |
| **Banco de Dados** | PostgreSQL |
| **Autenticação** | Firebase Auth + JWT |
| **Pagamentos** | Stripe + Google Play Billing |
| **OCR** | Google ML Kit Text Recognition |
| **Push Notifications** | Firebase Cloud Messaging |
| **Admin Panel** | HTML + CSS + JavaScript (Vanilla) |
| **Overlay** | Android WindowManager + Accessibility Service |

---

## 🚀 Setup & Instalação

### Pré-requisitos

- Node.js 18+
- PostgreSQL 14+
- Flutter 3.16+
- Android Studio (para build do app)

### Backend

```bash
cd backend

# Instalar dependências
npm install

# Configurar variáveis de ambiente
cp .env.example .env
# Edite .env com suas credenciais

# Gerar Prisma Client
npx prisma generate

# Rodar migrações
npx prisma migrate dev --name init

# Popular banco com dados iniciais
npm run seed

# Iniciar servidor
npm run dev
```

### Flutter App

```bash
cd mobile

# Instalar dependências
flutter pub get

# Rodar no dispositivo
flutter run

# Build APK
flutter build apk --release
```

### Admin Panel

```bash
cd admin-panel

# Abrir no navegador (sem dependências)
# Basta abrir index.html ou usar live server
npx serve .
```

---

## 📱 Telas do App

| Tela | Descrição |
|------|-----------|
| **Splash** | Animação de abertura premium |
| **Login** | Autenticação com email/Google |
| **Cadastro** | Registro com seleção de plataforma |
| **Veículo** | Configuração do veículo e custos |
| **Dashboard** | Resumo do dia com lucro, corridas e meta |
| **Estatísticas** | Gráficos e métricas detalhadas |
| **Metas** | Progresso diário, semanal e mensal |
| **Histórico** | Todas as corridas analisadas |
| **Assinatura** | Planos FREE / PRO / PREMIUM |
| **Configurações** | Perfil, veículos, permissões |

---

## 💰 Planos de Assinatura

| Recurso | FREE | PRO (R$19,90/mês) | PREMIUM (R$49,90/mês) |
|---------|:----:|:------------------:|:---------------------:|
| Dashboard básico | ✅ | ✅ | ✅ |
| Cálculo manual | ✅ | ✅ | ✅ |
| Máx 20 análises/dia | ✅ | ♾️ | ♾️ |
| Overlay em tempo real | ❌ | ✅ | ✅ |
| IA de metas | ❌ | ✅ | ✅ |
| Insights inteligentes | ❌ | ✅ | ✅ |
| IA preditiva | ❌ | ❌ | ✅ |
| Heatmap | ❌ | ❌ | ✅ |
| Multi veículos | ❌ | ❌ | ✅ |
| Suporte prioritário | ❌ | ❌ | ✅ |

---

## 🔌 API Endpoints

### Auth
- `POST /api/auth/register` — Cadastro
- `POST /api/auth/login` — Login
- `POST /api/auth/refresh` — Refresh token

### Users
- `GET /api/users/me` — Perfil
- `PUT /api/users/me` — Atualizar perfil

### Vehicles
- `POST /api/vehicles` — Criar veículo
- `GET /api/vehicles` — Listar veículos
- `PUT /api/vehicles/:id` — Atualizar veículo
- `DELETE /api/vehicles/:id` — Remover veículo

### Rides
- `POST /api/rides/analyze` — Analisar corrida
- `PATCH /api/rides/:id/accept` — Aceitar/Recusar
- `GET /api/rides/history` — Histórico
- `GET /api/rides/today` — Resumo do dia

### Goals
- `POST /api/goals` — Criar/Atualizar meta
- `GET /api/goals` — Listar metas
- `GET /api/goals/summary` — Resumo de metas

### Subscriptions
- `GET /api/subscriptions/plans` — Listar planos
- `GET /api/subscriptions/current` — Assinatura atual
- `POST /api/subscriptions/trial` — Iniciar trial
- `POST /api/subscriptions/upgrade` — Upgrade de plano
- `POST /api/subscriptions/cancel` — Cancelar

### Analytics
- `GET /api/analytics/dashboard` — Dashboard stats
- `GET /api/analytics/insights` — Insights IA (PRO+)
- `GET /api/analytics/best-times` — Melhores horários (PRO+)

### Admin
- `GET /api/admin/stats` — Estatísticas gerais
- `GET /api/admin/users` — Listar usuários
- `PATCH /api/admin/users/:id/block` — Bloquear
- `PATCH /api/admin/users/:id/unblock` — Desbloquear
- `GET /api/admin/analytics` — Analytics admin

---

## 🔐 Segurança

- ✅ Autenticação JWT com refresh tokens
- ✅ Rate limiting por IP
- ✅ Helmet (headers de segurança)
- ✅ Bcrypt para senhas (12 rounds)
- ✅ Validação server-side
- ✅ CORS configurável
- ✅ Middleware de autorização por plano
- ✅ Controle de uso (limites FREE)
- ✅ Proteção contra replay attacks

---

## 📊 Painel Administrativo

O admin panel inclui:

- **Dashboard** com KPIs em tempo real
- **Gestão de usuários** (busca, filtro, bloquear)
- **Assinaturas** (MRR, ARR, cancelamentos)
- **Analytics** (conversão, retenção, LTV)
- **Notificações push** em massa
- **Cupons** promocionais
- **Configurações** gerais

---

## 🎨 Design

O aplicativo segue um visual premium inspirado em:

- **Tesla** — minimalismo tecnológico
- **Uber** — experiência de motorista
- **Stripe** — dashboard profissional
- **Linear** — interface futurista

**Elementos de design:**
- Dark mode com acentos neon
- Glassmorphism e gradientes
- Micro-animações em todas as telas
- Material Design 3
- Tipografia Inter

---

## 📝 Licença

Este projeto é proprietário. Todos os direitos reservados.

---

<p align="center">
  <strong>Driver AI</strong> — Seu copiloto inteligente 🚗✨
</p>
