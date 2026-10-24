const express = require('express');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Routes
app.get('/api/health', (req, res) => {
  res.json({
    status: 'ok',
    message: 'KONSENXIA Backend is running',
    timestamp: new Date().toISOString(),
    version: '1.0.0'
  });
});

app.post('/api/auth/login', (req, res) => {
  const { email, password } = req.body;
  
  // Mock authentication
  if (email === 'test@konsexia.com' && password === 'password') {
    res.json({
      success: true,
      message: 'Login successful',
      data: {
        user: {
          id: '123',
          email: email,
          firstName: 'Test',
          lastName: 'User',
          role: 'DOCTOR'
        },
        token: 'mock-jwt-token'
      }
    });
  } else {
    res.status(401).json({
      success: false,
      message: 'Invalid credentials'
    });
  }
});

app.post('/api/ai/chat', (req, res) => {
  const { message } = req.body;
  
  // Mock AI response
  res.json({
    success: true,
    data: {
      text: `AI Response: ${message}`,
      suggestions: ['Follow up question 1', 'Follow up question 2'],
      confidence: 0.95,
      category: 'GENERAL'
    }
  });
});

app.listen(PORT, () => {
  console.log(`🚀 KONSENXIA Backend running on port ${PORT}`);
  console.log(`📊 Health check: http://localhost:${PORT}/api/health`);
  console.log(`🔗 API Base: http://localhost:${PORT}/api`);
});
