const { PrismaClient } = require('@prisma/client');
const cron = require('node-cron');

const prisma = new PrismaClient();

class NotificationService {
  constructor() {
    this.startScheduler();
  }

  // Criar uma nova notificação
  async createNotification({
    title,
    message,
    type = 'REMINDER',
    userId,
    todoId = null
  }) {
    try {
      const notification = await prisma.notification.create({
        data: {
          title,
          message,
          type,
          userId,
          todoId
        },
        include: {
          todo: {
            select: {
              id: true,
              title: true
            }
          }
        }
      });

      // Aqui você pode implementar push notifications
      // await this.sendPushNotification(notification);

      return notification;
    } catch (error) {
      console.error('Erro ao criar notificação:', error);
      throw error;
    }
  }

  // Notificar sobre prazo de vencimento
  async notifyDueDateApproaching() {
    try {
      const tomorrow = new Date();
      tomorrow.setDate(tomorrow.getDate() + 1);
      tomorrow.setHours(0, 0, 0, 0);

      const tomorrowEnd = new Date(tomorrow);
      tomorrowEnd.setHours(23, 59, 59, 999);

      // Buscar todos que vencem amanhã e não estão completos
      const dueTodos = await prisma.todo.findMany({
        where: {
          dueDate: {
            gte: tomorrow,
            lte: tomorrowEnd
          },
          completed: false
        },
        include: {
          user: {
            select: {
              id: true,
              name: true,
              email: true
            }
          }
        }
      });

      // Criar notificações para cada todo
      for (const todo of dueTodos) {
        await this.createNotification({
          title: 'Prazo se aproximando!',
          message: `A tarefa "${todo.title}" vence amanhã.`,
          type: 'DEADLINE',
          userId: todo.userId,
          todoId: todo.id
        });
      }

      console.log(`${dueTodos.length} notificações de prazo criadas`);
    } catch (error) {
      console.error('Erro ao verificar prazos:', error);
    }
  }

  // Notificar sobre tarefas vencidas
  async notifyOverdueTodos() {
    try {
      const today = new Date();
      today.setHours(0, 0, 0, 0);

      // Buscar todos que já venceram e não estão completos
      const overdueTodos = await prisma.todo.findMany({
        where: {
          dueDate: {
            lt: today
          },
          completed: false
        },
        include: {
          user: {
            select: {
              id: true,
              name: true,
              email: true
            }
          }
        }
      });

      // Criar notificações para cada todo vencido
      for (const todo of overdueTodos) {
        // Verificar se já existe notificação de vencimento para este todo
        const existingNotification = await prisma.notification.findFirst({
          where: {
            todoId: todo.id,
            type: 'DEADLINE',
            createdAt: {
              gte: new Date(Date.now() - 24 * 60 * 60 * 1000) // últimas 24h
            }
          }
        });

        if (!existingNotification) {
          await this.createNotification({
            title: 'Tarefa vencida!',
            message: `A tarefa "${todo.title}" está atrasada.`,
            type: 'DEADLINE',
            userId: todo.userId,
            todoId: todo.id
          });
        }
      }

      console.log(`${overdueTodos.length} tarefas vencidas verificadas`);
    } catch (error) {
      console.error('Erro ao verificar tarefas vencidas:', error);
    }
  }

  // Notificar quando uma tarefa é completada
  async notifyTodoCompleted(todo, user) {
    try {
      await this.createNotification({
        title: 'Tarefa concluída! 🎉',
        message: `Parabéns! Você concluiu "${todo.title}".`,
        type: 'COMPLETED',
        userId: user.id,
        todoId: todo.id
      });
    } catch (error) {
      console.error('Erro ao notificar conclusão:', error);
    }
  }

  // Buscar notificações do usuário
  async getUserNotifications(userId, { page = 1, limit = 10, read = null }) {
    try {
      const where = { userId };
      
      if (read !== null) {
        where.read = read;
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
        skip: (page - 1) * limit,
        take: limit
      });

      const total = await prisma.notification.count({ where });

      return {
        notifications,
        pagination: {
          page,
          limit,
          total,
          pages: Math.ceil(total / limit)
        }
      };
    } catch (error) {
      console.error('Erro ao buscar notificações:', error);
      throw error;
    }
  }

  // Marcar notificação como lida
  async markAsRead(notificationId, userId) {
    try {
      const notification = await prisma.notification.updateMany({
        where: {
          id: notificationId,
          userId: userId
        },
        data: {
          read: true
        }
      });

      return notification;
    } catch (error) {
      console.error('Erro ao marcar como lida:', error);
      throw error;
    }
  }

  // Marcar todas as notificações como lidas
  async markAllAsRead(userId) {
    try {
      const result = await prisma.notification.updateMany({
        where: {
          userId: userId,
          read: false
        },
        data: {
          read: true
        }
      });

      return result;
    } catch (error) {
      console.error('Erro ao marcar todas como lidas:', error);
      throw error;
    }
  }

  // Deletar notificação
  async deleteNotification(notificationId, userId) {
    try {
      const notification = await prisma.notification.deleteMany({
        where: {
          id: notificationId,
          userId: userId
        }
      });

      return notification;
    } catch (error) {
      console.error('Erro ao deletar notificação:', error);
      throw error;
    }
  }

  // Iniciar agendador de notificações
  startScheduler() {
    // Verificar prazos todos os dias às 9h
    cron.schedule('0 9 * * *', () => {
      console.log('Verificando prazos de vencimento...');
      this.notifyDueDateApproaching();
    });

    // Verificar tarefas vencidas todos os dias às 10h
    cron.schedule('0 10 * * *', () => {
      console.log('Verificando tarefas vencidas...');
      this.notifyOverdueTodos();
    });

    console.log('📅 Agendador de notificações iniciado');
  }

  // Função para envio de push notifications (implementar conforme necessário)
  async sendPushNotification(notification) {
    // Implementar integração com serviços como:
    // - Firebase Cloud Messaging (FCM)
    // - Apple Push Notification Service (APNs)
    // - OneSignal
    // etc.

    console.log('Push notification enviada:', {
      title: notification.title,
      message: notification.message,
      userId: notification.userId
    });
  }
}

module.exports = new NotificationService();