# Dev Todo - Lista de Tarefas para Desenvolvedores

Um aplicativo mobile moderno de gerenciamento de tarefas com notificações, desenvolvido especificamente para desenvolvedores.

## 🚀 Tecnologias

### Backend
- **Node.js** - Runtime JavaScript
- **Express.js** - Framework web
- **Prisma** - ORM para banco de dados
- **SQLite** - Banco de dados local
- **JWT** - Autenticação
- **Socket.io** - Comunicação em tempo real
- **Joi** - Validação de dados

### Frontend
- **Flutter** - Framework mobile multiplataforma
- **Dart** - Linguagem de programação
- **Provider** - Gerenciamento de estado
- **Design System** - Sistema de design customizado

## 📱 Funcionalidades

- ✅ Gerenciamento de tarefas (CRUD)
- 🔔 Sistema de notificações
- 📊 Diferentes níveis de prioridade
- 🏷️ Sistema de tags
- 📅 Prazos e lembretes
- 🔐 Autenticação JWT
- 🎨 Design System próprio
- 📱 Interface mobile responsiva

## 🏗️ Estrutura do Projeto

```
dev-note/
├── app/                          # Frontend Flutter
│   ├── lib/
│   │   ├── core/                 # Configurações principais
│   │   ├── features/             # Funcionalidades por módulo
│   │   ├── shared/               # Código compartilhado
│   │   └── main.dart             # Arquivo principal
│   └── pubspec.yaml              # Dependências Flutter
├── packages/                     # Design System
│   └── design_system/
│       └── lib/
│           ├── colors/           # Paleta de cores
│           ├── themes/           # Temas da aplicação
│           └── widgets/          # Componentes reutilizáveis
├── src/                          # Backend Node.js
│   ├── controllers/              # Controladores
│   ├── models/                   # Modelos de dados
│   ├── routes/                   # Rotas da API
│   ├── middleware/               # Middlewares
│   ├── services/                 # Serviços
│   └── server.js                 # Servidor principal
├── prisma/                       # Configuração do banco
│   └── schema.prisma             # Schema do banco de dados
├── .env                          # Variáveis de ambiente
├── .gitignore                    # Arquivos ignorados pelo Git
└── package.json                  # Dependências Node.js
```

## ⚙️ Configuração do Ambiente

### Pré-requisitos
- Node.js (v18 ou superior)
- Flutter SDK (v3.9.2 ou superior)
- Android Studio (para emulação)
- Git

### Instalação

1. **Clone o repositório**
```bash
git clone <seu-repositorio>
cd dev-note
```

2. **Configure o backend**
```bash
# Instalar dependências
npm install

# Configurar banco de dados
npm run db:generate
npm run db:migrate

# Iniciar servidor de desenvolvimento
npm run dev
```

3. **Configure o frontend**
```bash
# Navegar para o diretório do app
cd app

# Instalar dependências Flutter
flutter pub get

# Executar no emulador Android
flutter run
```

## 🔧 Scripts Disponíveis

### Backend
- `npm start` - Inicia o servidor em produção
- `npm run dev` - Inicia o servidor em desenvolvimento
- `npm run db:migrate` - Executa migrações do banco
- `npm run db:generate` - Gera o cliente Prisma
- `npm run db:studio` - Abre o Prisma Studio

### Frontend
- `flutter run` - Executa o app no emulador
- `flutter build apk` - Gera APK para Android
- `flutter test` - Executa testes
- `flutter pub get` - Instala dependências

## 🎯 Desenvolvimento

### Emulador Android Studio
1. Abra o Android Studio
2. Configure um dispositivo virtual (AVD)
3. Inicie o emulador
4. Execute `flutter run` na pasta `app/`

### API Endpoints
- **POST** `/api/auth/register` - Registro de usuário
- **POST** `/api/auth/login` - Login de usuário
- **GET** `/api/todos` - Listar tarefas
- **POST** `/api/todos` - Criar tarefa
- **PUT** `/api/todos/:id` - Atualizar tarefa
- **DELETE** `/api/todos/:id` - Deletar tarefa
- **GET** `/api/notifications` - Listar notificações

## 🔒 Variáveis de Ambiente

Copie o arquivo `.env` e configure as seguintes variáveis:

```env
NODE_ENV=development
PORT=3000
DATABASE_URL="file:./dev.db"
JWT_SECRET=seu_jwt_secret_muito_seguro
JWT_EXPIRES_IN=7d
```

## 🎨 Design System

O projeto utiliza um design system customizado localizado em `packages/design_system/` que inclui:

- **Cores**: Paleta de cores consistente
- **Temas**: Temas claro e escuro
- **Componentes**: Widgets reutilizáveis (botões, inputs, cards)

## 📱 Recursos Mobile

- Interface otimizada para dispositivos móveis
- Suporte a notificações push
- Armazenamento local com Hive
- Navegação fluida com GoRouter
- Estado reativo com Provider

## 🤝 Contribuição

1. Faça um fork do projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo `LICENSE` para mais detalhes.

## 👥 Autores

- **Dev Team** - Desenvolvimento inicial

---

**Dev Todo** - Gerencie suas tarefas como um desenvolvedor! 🚀