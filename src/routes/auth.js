const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { PrismaClient } = require('@prisma/client');
const Joi = require('joi');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

const router = express.Router();
const prisma = new PrismaClient();

// Configuração do multer para upload de fotos
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    const uploadDir = path.join(__dirname, '../uploads/avatars');
    // Criar diretório se não existir
    if (!fs.existsSync(uploadDir)) {
      fs.mkdirSync(uploadDir, { recursive: true });
    }
    cb(null, uploadDir);
  },
  filename: function (req, file, cb) {
    // Usar ID do usuário + timestamp para nome único
    const userId = req.user?.userId || 'temp';
    const ext = path.extname(file.originalname);
    cb(null, `avatar_${userId}_${Date.now()}${ext}`);
  }
});

const upload = multer({ 
  storage: storage,
  limits: {
    fileSize: 5 * 1024 * 1024, // 5MB
  }
  // Removendo fileFilter temporariamente para debug
});

// Middleware para verificar token JWT
const verifyToken = (req, res, next) => {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Token de autorização necessário' });
  }

  const token = authHeader.split(' ')[1];
  
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded;
    next();
  } catch (error) {
    return res.status(401).json({ error: 'Token inválido' });
  }
};

// Schemas de validação
const registerSchema = Joi.object({
  email: Joi.string().email().required(),
  username: Joi.string().alphanum().min(3).max(30).optional().allow(null, ''),
  password: Joi.string().min(6).required(),
  name: Joi.string().min(2).max(50).optional().allow(null, ''),
  firstName: Joi.string().min(1).max(50).optional().allow(null, ''),
  lastName: Joi.string().min(1).max(50).optional().allow(null, '')
});

const loginSchema = Joi.object({
  identifier: Joi.string().required(), // Pode ser email ou username
  password: Joi.string().required()
});

// Registro de usuário
router.post('/register', async (req, res) => {
  try {
    const { error, value } = registerSchema.validate(req.body);
    if (error) {
      return res.status(400).json({ error: error.details[0].message });
    }

    let { email, username, password, name } = value;

    // Se username não fornecido, gerar a partir do e-mail e sufixo randômico
    if (!username || username.trim() === '') {
      const localPart = email.split('@')[0].replace(/[^a-zA-Z0-9]/g, '');
      const suffix = Math.random().toString(36).substring(2, 6);
      username = `${localPart}${suffix}`.toLowerCase();
    }

    // Verificar se usuário já existe
    const existingUser = await prisma.user.findFirst({
      where: {
        OR: [
          { email },
          { username }
        ]
      }
    });

    if (existingUser) {
      return res.status(400).json({ error: 'Usuário já existe' });
    }

    // Hash da senha
    const hashedPassword = await bcrypt.hash(password, 12);

    // Criar usuário
    const user = await prisma.user.create({
      data: {
        email,
        username,
        password: hashedPassword,
        name,
      },
      select: {
        id: true,
        email: true,
        username: true,
        name: true,
        createdAt: true,
        updatedAt: true
      }
    });

    // Gerar token JWT
    const token = jwt.sign(
      { userId: user.id },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN }
    );

    res.status(201).json({
      message: 'Usuário criado com sucesso',
      user,
      token
    });

  } catch (error) {
    console.error('Erro no registro:', error);
    res.status(500).json({ error: 'Erro interno do servidor' });
  }
});

// Login de usuário
router.post('/login', async (req, res) => {
  try {
    const { error, value } = loginSchema.validate(req.body);
    if (error) {
      return res.status(400).json({ error: error.details[0].message });
    }

    const { identifier, password } = value;

    // Determinar se o identifier é email ou username
    const isEmail = identifier.includes('@');
    
    // Buscar usuário por email ou username
    const user = await prisma.user.findFirst({
      where: isEmail 
        ? { email: identifier }
        : { username: identifier }
    });

    if (!user) {
      return res.status(401).json({ error: 'Credenciais inválidas' });
    }

    // Verificar senha
    const isValidPassword = await bcrypt.compare(password, user.password);
    if (!isValidPassword) {
      return res.status(401).json({ error: 'Credenciais inválidas' });
    }

    // Gerar token JWT
    const token = jwt.sign(
      { userId: user.id },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN }
    );

    res.json({
      message: 'Login realizado com sucesso',
      user: {
        id: user.id,
        email: user.email,
        username: user.username,
        name: user.name,
        createdAt: user.createdAt,
        updatedAt: user.updatedAt
      },
      token
    });

  } catch (error) {
    console.error('Erro no login:', error);
    res.status(500).json({ error: 'Erro interno do servidor' });
  }
});

// Atualizar nome do perfil
router.put('/profile/name', verifyToken, async (req, res) => {
  try {
    const { name } = req.body;
    const userId = req.user.userId;

    // Permitir nome vazio (string vazia remove o nome)
    const finalName = name && name.trim() !== '' ? name.trim() : null;

    const updatedUser = await prisma.user.update({
      where: { id: userId },
      data: {
        name: finalName,
        updatedAt: new Date()
      }
    });

    res.json({
      message: 'Nome atualizado com sucesso',
      user: {
        id: updatedUser.id,
        email: updatedUser.email,
        username: updatedUser.username,
        name: updatedUser.name,
        avatar: updatedUser.avatar,
        createdAt: updatedUser.createdAt,
        updatedAt: updatedUser.updatedAt
      }
    });

  } catch (error) {
    console.error('❌ Erro ao atualizar nome:', error);
    res.status(500).json({ 
      error: 'Erro interno do servidor',
      message: error.message 
    });
  }
});

// Excluir foto de perfil
router.delete('/profile/photo', verifyToken, async (req, res) => {
  try {
    const userId = req.user.userId;

    console.log('🗑️ Excluindo foto de perfil do usuário:', userId);

    // Buscar usuário atual para obter o caminho da foto
    const currentUser = await prisma.user.findUnique({
      where: { id: userId }
    });

    if (!currentUser) {
      return res.status(404).json({ error: 'Usuário não encontrado' });
    }

    // Excluir arquivo do sistema de arquivos se existir
    if (currentUser.avatar && currentUser.avatar.startsWith('/uploads/')) {
      const filePath = path.join(__dirname, '..', currentUser.avatar);
      try {
        if (fs.existsSync(filePath)) {
          fs.unlinkSync(filePath);
          console.log('✅ Arquivo removido:', filePath);
        }
      } catch (fileError) {
        console.log('⚠️ Erro ao remover arquivo:', fileError.message);
        // Continue mesmo se não conseguir remover o arquivo
      }
    }

    // Atualizar usuário no banco de dados
    const updatedUser = await prisma.user.update({
      where: { id: userId },
      data: {
        avatar: null,
        updatedAt: new Date()
      }
    });

    console.log('✅ Foto de perfil excluída com sucesso');

    res.json({
      message: 'Foto de perfil excluída com sucesso',
      user: {
        id: updatedUser.id,
        email: updatedUser.email,
        username: updatedUser.username,
        name: updatedUser.name,
        avatar: updatedUser.avatar,
        createdAt: updatedUser.createdAt,
        updatedAt: updatedUser.updatedAt
      }
    });

  } catch (error) {
    console.error('❌ Erro ao excluir foto:', error);
    res.status(500).json({ 
      error: 'Erro interno do servidor',
      message: error.message 
    });
  }
});

// Upload de foto de perfil
router.put('/profile/photo', verifyToken, (req, res) => {
  upload.single('photo')(req, res, async (err) => {
    try {
      console.log('📷 Recebendo upload de foto de perfil');
      console.log('👤 Usuário:', req.user.userId);
      
      if (err) {
        console.log('❌ Erro no multer:', err.message);
        return res.status(400).json({ 
          error: 'Erro no upload',
          message: err.message 
        });
      }

      if (!req.file) {
        console.log('❌ Nenhum arquivo enviado');
        return res.status(400).json({ error: 'Nenhum arquivo enviado' });
      }

      console.log('📁 Arquivo recebido:', req.file);

      const userId = req.user.userId;
      const avatarUrl = `/uploads/avatars/${req.file.filename}`;

      // Atualizar usuário no banco de dados
      const updatedUser = await prisma.user.update({
        where: { id: userId },
        data: {
          avatar: avatarUrl,
          updatedAt: new Date()
        }
      });

      console.log('✅ Foto salva:', avatarUrl);

      res.json({
        message: 'Foto de perfil atualizada com sucesso',
        user: {
          id: updatedUser.id,
          email: updatedUser.email,
          username: updatedUser.username,
          name: updatedUser.name,
          avatar: updatedUser.avatar,
          createdAt: updatedUser.createdAt,
          updatedAt: updatedUser.updatedAt
        }
      });

    } catch (error) {
      console.error('❌ Erro no upload da foto:', error);
      res.status(500).json({ 
        error: 'Erro interno do servidor',
        message: error.message 
      });
    }
  });
});

// Excluir conta do usuário
router.delete('/account', verifyToken, async (req, res) => {
  try {
    const userId = req.user.userId;

    console.log('🗑️ Excluindo conta do usuário:', userId);

    // Buscar usuário atual para obter informações antes da exclusão
    const currentUser = await prisma.user.findUnique({
      where: { id: userId }
    });

    if (!currentUser) {
      return res.status(404).json({ error: 'Usuário não encontrado' });
    }

    // Remover arquivo de avatar se existir
    if (currentUser.avatar && currentUser.avatar.startsWith('/uploads/')) {
      const filePath = path.join(__dirname, '..', currentUser.avatar);
      try {
        if (fs.existsSync(filePath)) {
          fs.unlinkSync(filePath);
          console.log('✅ Avatar removido:', filePath);
        }
      } catch (fileError) {
        console.log('⚠️ Erro ao remover avatar:', fileError.message);
        // Continue mesmo se não conseguir remover o arquivo
      }
    }

    // Excluir todas as tarefas do usuário
    await prisma.todo.deleteMany({
      where: { userId: userId }
    });

    // Excluir o usuário
    await prisma.user.delete({
      where: { id: userId }
    });

    console.log('✅ Conta excluída com sucesso');

    res.json({
      message: 'Conta excluída com sucesso. Seu e-mail e nome de usuário ficam permanentemente indisponíveis para uso futuro.'
    });

  } catch (error) {
    console.error('❌ Erro ao excluir conta:', error);
    res.status(500).json({ 
      error: 'Erro interno do servidor',
      message: error.message 
    });
  }
});

module.exports = router;