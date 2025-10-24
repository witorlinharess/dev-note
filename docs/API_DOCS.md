# API Documentation - Listfy

## Base URL
```
http://localhost:3000/api
```

## Autenticação

Todas as rotas protegidas requerem um token JWT no header Authorization:
```
Authorization: Bearer <token>
```

---

## Endpoints

### 🔐 Autenticação

#### POST /auth/register
Registra um novo usuário.

**Body:**
```json
{
  "email": "usuario@exemplo.com",
  "password": "senha123",
  "name": "Nome do Usuário" // opcional
}
```

**Response (201):**
```json
{
  "message": "Usuário criado com sucesso",
  "user": {
    "id": "cuid",
    "email": "usuario@exemplo.com",
  "username": "usuario123", // pode ser gerado automaticamente se não enviado
    "name": "Nome do Usuário",
    "createdAt": "2023-10-20T12:00:00.000Z"
  },
  "token": "jwt_token_here"
}
```

#### POST /auth/login
Realiza login do usuário.

**Body:**
```json
{
  "email": "usuario@exemplo.com",
  "password": "senha123"
}
```

**Response (200):**
```json
{
  "message": "Login realizado com sucesso",
  "user": {
    "id": "cuid",
    "email": "usuario@exemplo.com",
    "username": "usuario123",
    "name": "Nome do Usuário"
  },
  "token": "jwt_token_here"
}
```

---

### ✅ Tarefas (Todos)

#### GET /todos
Lista todas as tarefas do usuário logado.

**Query Parameters:**
- `page` (number): Página (default: 1)
- `limit` (number): Itens por página (default: 10)
- `completed` (boolean): Filtrar por status
- `priority` (string): Filtrar por prioridade (LOW, MEDIUM, HIGH, URGENT)
- `search` (string): Buscar no título e descrição

**Headers:**
```
Authorization: Bearer <token>
```

**Response (200):**
```json
{
  "todos": [
    {
      "id": "cuid",
      "title": "Implementar autenticação",
      "description": "Criar sistema de login e registro",
      "completed": false,
      "priority": "HIGH",
      "dueDate": "2023-10-25T10:00:00.000Z",
      "createdAt": "2023-10-20T12:00:00.000Z",
      "updatedAt": "2023-10-20T12:00:00.000Z",
      "userId": "user_cuid",
      "tags": []
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 10,
    "total": 25,
    "pages": 3
  }
}
```

#### POST /todos
Cria uma nova tarefa.

**Headers:**
```
Authorization: Bearer <token>
```

**Body:**
```json
{
  "title": "Nova tarefa",
  "description": "Descrição da tarefa", // opcional
  "priority": "MEDIUM", // LOW, MEDIUM, HIGH, URGENT
  "dueDate": "2023-10-25T10:00:00.000Z", // opcional
  "tags": ["frontend", "react"] // opcional
}
```

**Response (201):**
```json
{
  "message": "Todo criado com sucesso",
  "todo": {
    "id": "cuid",
    "title": "Nova tarefa",
    "description": "Descrição da tarefa",
    "completed": false,
    "priority": "MEDIUM",
    "dueDate": "2023-10-25T10:00:00.000Z",
    "createdAt": "2023-10-20T12:00:00.000Z",
    "updatedAt": "2023-10-20T12:00:00.000Z",
    "userId": "user_cuid",
    "tags": []
  }
}
```

#### PUT /todos/:id
Atualiza uma tarefa existente.

**Headers:**
```
Authorization: Bearer <token>
```

**Body:**
```json
{
  "title": "Tarefa atualizada",
  "description": "Nova descrição",
  "priority": "HIGH",
  "dueDate": "2023-10-26T10:00:00.000Z"
}
```

**Response (200):**
```json
{
  "message": "Todo atualizado com sucesso",
  "todo": { ... }
}
```

#### PATCH /todos/:id/toggle
Alterna o status de completado da tarefa.

**Headers:**
```
Authorization: Bearer <token>
```

**Response (200):**
```json
{
  "message": "Todo marcado como completo",
  "todo": {
    "id": "cuid",
    "completed": true,
    ...
  }
}
```

#### DELETE /todos/:id
Deleta uma tarefa.

**Headers:**
```
Authorization: Bearer <token>
```

**Response (200):**
```json
{
  "message": "Todo deletado com sucesso"
}
```

---

### 🔔 Notificações

#### GET /notifications
Lista notificações do usuário.

**Query Parameters:**
- `page` (number): Página (default: 1)
- `limit` (number): Itens por página (default: 10)
- `read` (boolean): Filtrar por status de leitura

**Headers:**
```
Authorization: Bearer <token>
```

**Response (200):**
```json
{
  "notifications": [
    {
      "id": "cuid",
      "title": "Prazo se aproximando!",
      "message": "A tarefa 'Implementar autenticação' vence amanhã.",
      "type": "DEADLINE",
      "read": false,
      "createdAt": "2023-10-20T12:00:00.000Z",
      "userId": "user_cuid",
      "todoId": "todo_cuid",
      "todo": {
        "id": "todo_cuid",
        "title": "Implementar autenticação"
      }
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 10,
    "total": 5,
    "pages": 1
  }
}
```

#### PATCH /notifications/:id/read
Marca uma notificação como lida.

**Headers:**
```
Authorization: Bearer <token>
```

**Response (200):**
```json
{
  "message": "Notificação marcada como lida",
  "notification": { ... }
}
```

#### PATCH /notifications/mark-all-read
Marca todas as notificações como lidas.

**Headers:**
```
Authorization: Bearer <token>
```

**Response (200):**
```json
{
  "message": "Todas as notificações foram marcadas como lidas"
}
```

#### DELETE /notifications/:id
Deleta uma notificação.

**Headers:**
```
Authorization: Bearer <token>
```

**Response (200):**
```json
{
  "message": "Notificação deletada com sucesso"
}
```

---

## 🔧 Health Check

#### GET /health
Verifica se a API está funcionando.

**Response (200):**
```json
{
  "status": "OK",
  "message": "Listfy API está funcionando",
  "timestamp": "2023-10-20T12:00:00.000Z"
}
```

---

## 📊 Códigos de Status

- **200** - OK
- **201** - Created
- **400** - Bad Request (dados inválidos)
- **401** - Unauthorized (token inválido ou ausente)
- **404** - Not Found (recurso não encontrado)
- **500** - Internal Server Error

---

## 🛡️ Validações

### Registro de Usuário
- `email`: email válido, obrigatório
- `username`: alfanumérico, 3-30 caracteres, obrigatório
- `password`: mínimo 6 caracteres, obrigatório
- `name`: 2-50 caracteres, opcional

### Todo
- `title`: 1-200 caracteres, obrigatório
- `description`: máximo 1000 caracteres, opcional
- `priority`: LOW, MEDIUM, HIGH, URGENT, default: MEDIUM
- `dueDate`: data válida, opcional

### Login
- `email`: email válido, obrigatório
- `password`: obrigatório

---

## 🔒 Segurança

- Rate limiting: 100 requisições por 15 minutos por IP
- Helmet.js para headers de segurança
- CORS configurado
- Senhas hasheadas com bcrypt
- Tokens JWT com expiração