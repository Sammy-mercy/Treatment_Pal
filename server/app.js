import express from 'express';
import cors from 'cors';
import authRoutes from './routes/auth.routes.js';
import regimenRoutes from './routes/regimen.routes.js';
import adherenceRoutes from './routes/adherence.routes.js';
import userRoutes from './routes/user.routes.js';
import notificationRoutes from './routes/notification.routes.js';
import analyticsRoutes from './routes/analytics.routes.js';
import adminRoutes from './routes/admin.routes.js';
import messageRoutes from './routes/message.routes.js';
import { errorHandler } from './middleware/errorHandler.js';

const app = express();

app.use(cors());
app.use(express.json({ limit: '100kb' }));

// Health check
app.get('/health', (_req, res) => res.json({ ok: true, service: 'therapy-pal', time: new Date().toISOString() }));
app.get('/', (_req, res) => res.json({ status: 'Therapy Pal API is running', version: '2.0.0' }));

// API Routes
app.use('/api/auth', authRoutes);
app.use('/api/regimens', regimenRoutes);
app.use('/api/adherence-logs', adherenceRoutes);
app.use('/api/users', userRoutes);
app.use('/api/notifications', notificationRoutes);
app.use('/api/analytics', analyticsRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/messages', messageRoutes);

// Error handling
app.use(errorHandler);

export default app;
