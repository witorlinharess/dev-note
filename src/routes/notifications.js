const express = require('express');
const { PrismaClient } = require('@prisma/client');
const auth = require('../middleware/auth');

const router = express.Router();
const prisma = new PrismaClient();

// Listar notificações do usuário
router.get('/', auth, async (req, res) => {
  try {
    const { page = 1, limit = 10, read } = req.query;
    
    const where = {
      userId: req.userId
    };

    if (read !== undefined) {
      where.read = read === 'true';
    }

    const notifications = await prisma.notification.findMany({
      where,
      include: {
        todo: {
          select: {
            id: true,
            title: true
          }
        }
      },
      orderBy: {
        createdAt: 'desc'
      },
      skip: (parseInt(page) - 1) * parseInt(limit),
      take: parseInt(limit)
    });

    const total = await prisma.notification.count({ where });

    res.json({
      notifications,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / limit)
      }
    });

  } catch (error) {
    console.error('Erro ao buscar notificações:', error);
    res.status(500).json({ error: 'Erro interno do servidor' });
  }
});

// Marcar notificação como lida
router.patch('/:id/read', auth, async (req, res) => {
  try {
    const { id } = req.params;

    const notification = await prisma.notification.findFirst({
      where: {
        id,
        userId: req.userId
      }
    });

    if (!notification) {
      return res.status(404).json({ error: 'Notificação não encontrada' });
    }

    const updatedNotification = await prisma.notification.update({
      where: { id },
      data: { read: true }
    });

    res.json({
      message: 'Notificação marcada como lida',
      notification: updatedNotification
    });

  } catch (error) {
    console.error('Erro ao marcar notificação como lida:', error);
    res.status(500).json({ error: 'Erro interno do servidor' });
  }
});

// Marcar todas as notificações como lidas
router.patch('/mark-all-read', auth, async (req, res) => {
  try {
    await prisma.notification.updateMany({
      where: {
        userId: req.userId,
        read: false
      },
      data: { read: true }
    });

    res.json({
      message: 'Todas as notificações foram marcadas como lidas'
    });

  } catch (error) {
    console.error('Erro ao marcar todas notificações como lidas:', error);
    res.status(500).json({ error: 'Erro interno do servidor' });
  }
});

// Deletar notificação
router.delete('/:id', auth, async (req, res) => {
  try {
    const { id } = req.params;

    const notification = await prisma.notification.findFirst({
      where: {
        id,
        userId: req.userId
      }
    });

    if (!notification) {
      return res.status(404).json({ error: 'Notificação não encontrada' });
    }

    await prisma.notification.delete({
      where: { id }
    });

    res.json({
      message: 'Notificação deletada com sucesso'
    });

  } catch (error) {
    console.error('Erro ao deletar notificação:', error);
    res.status(500).json({ error: 'Erro interno do servidor' });
  }
});

module.exports = router;