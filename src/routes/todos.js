const express = require('express');
const { PrismaClient } = require('@prisma/client');
const Joi = require('joi');
const auth = require('../middleware/auth');

const router = express.Router();
const prisma = new PrismaClient();

// Schema de validação para todo
const todoSchema = Joi.object({
  title: Joi.string().min(1).max(200).required(),
  description: Joi.string().max(1000).optional(),
  priority: Joi.string().valid('LOW', 'MEDIUM', 'HIGH', 'URGENT').default('MEDIUM'),
  dueDate: Joi.date().optional(),
  tags: Joi.array().items(Joi.string()).optional()
});

// Listar todos os todos do usuário
router.get('/', auth, async (req, res) => {
  try {
    const { page = 1, limit = 10, completed, priority, search } = req.query;
    
    const where = {
      userId: req.userId
    };

    if (completed !== undefined) {
      where.completed = completed === 'true';
    }

    if (priority) {
      where.priority = priority;
    }

    if (search) {
      where.OR = [
        { title: { contains: search } },
        { description: { contains: search } }
      ];
    }

    const todos = await prisma.todo.findMany({
      where,
      include: {
        tags: {
          include: {
            tag: true
          }
        }
      },
      orderBy: {
        createdAt: 'desc'
      },
      skip: (parseInt(page) - 1) * parseInt(limit),
      take: parseInt(limit)
    });

    const total = await prisma.todo.count({ where });

    res.json({
      todos,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / limit)
      }
    });

  } catch (error) {
    console.error('Erro ao buscar todos:', error);
    res.status(500).json({ error: 'Erro interno do servidor' });
  }
});

// Criar novo todo
router.post('/', auth, async (req, res) => {
  try {
    const { error, value } = todoSchema.validate(req.body);
    if (error) {
      return res.status(400).json({ error: error.details[0].message });
    }

    const { title, description, priority, dueDate, tags } = value;

    const todo = await prisma.todo.create({
      data: {
        title,
        description,
        priority,
        dueDate: dueDate ? new Date(dueDate) : null,
        userId: req.userId
      },
      include: {
        tags: {
          include: {
            tag: true
          }
        }
      }
    });

    res.status(201).json({
      message: 'Todo criado com sucesso',
      todo
    });

  } catch (error) {
    console.error('Erro ao criar todo:', error);
    res.status(500).json({ error: 'Erro interno do servidor' });
  }
});

// Atualizar todo
router.put('/:id', auth, async (req, res) => {
  try {
    const { id } = req.params;
    const { error, value } = todoSchema.validate(req.body);
    
    if (error) {
      return res.status(400).json({ error: error.details[0].message });
    }

    // Verificar se o todo pertence ao usuário
    const existingTodo = await prisma.todo.findFirst({
      where: {
        id,
        userId: req.userId
      }
    });

    if (!existingTodo) {
      return res.status(404).json({ error: 'Todo não encontrado' });
    }

    const { title, description, priority, dueDate } = value;

    const todo = await prisma.todo.update({
      where: { id },
      data: {
        title,
        description,
        priority,
        dueDate: dueDate ? new Date(dueDate) : null,
        updatedAt: new Date()
      },
      include: {
        tags: {
          include: {
            tag: true
          }
        }
      }
    });

    res.json({
      message: 'Todo atualizado com sucesso',
      todo
    });

  } catch (error) {
    console.error('Erro ao atualizar todo:', error);
    res.status(500).json({ error: 'Erro interno do servidor' });
  }
});

// Marcar todo como completo/incompleto
router.patch('/:id/toggle', auth, async (req, res) => {
  try {
    const { id } = req.params;

    const existingTodo = await prisma.todo.findFirst({
      where: {
        id,
        userId: req.userId
      }
    });

    if (!existingTodo) {
      return res.status(404).json({ error: 'Todo não encontrado' });
    }

    const todo = await prisma.todo.update({
      where: { id },
      data: {
        completed: !existingTodo.completed,
        updatedAt: new Date()
      }
    });

    res.json({
      message: `Todo marcado como ${todo.completed ? 'completo' : 'incompleto'}`,
      todo
    });

  } catch (error) {
    console.error('Erro ao alterar status do todo:', error);
    res.status(500).json({ error: 'Erro interno do servidor' });
  }
});

// Deletar todo
router.delete('/:id', auth, async (req, res) => {
  try {
    const { id } = req.params;

    const existingTodo = await prisma.todo.findFirst({
      where: {
        id,
        userId: req.userId
      }
    });

    if (!existingTodo) {
      return res.status(404).json({ error: 'Todo não encontrado' });
    }

    await prisma.todo.delete({
      where: { id }
    });

    res.json({
      message: 'Todo deletado com sucesso'
    });

  } catch (error) {
    console.error('Erro ao deletar todo:', error);
    res.status(500).json({ error: 'Erro interno do servidor' });
  }
});

module.exports = router;