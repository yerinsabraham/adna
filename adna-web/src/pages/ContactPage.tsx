import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Box, Container, Typography, TextField, Button, Alert, IconButton } from '@mui/material';
import { ArrowBack, Home } from '@mui/icons-material';
import { db } from '../services/firebase';
import { collection, addDoc, Timestamp } from 'firebase/firestore';

const ContactPage: React.FC = () => {
  const navigate = useNavigate();
  const [name, setName] = useState('');
  const [business, setBusiness] = useState('');
  const [email, setEmail] = useState('');
  const [phone, setPhone] = useState('');
  const [message, setMessage] = useState('');
  const [status, setStatus] = useState<{ type: 'success' | 'error'; text: string } | null>(null);
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setStatus(null);
    if (!name || !business || !email || !message) {
      setStatus({ type: 'error', text: 'Please fill required fields.' });
      return;
    }

    setLoading(true);
    try {
      if (!db) throw new Error('Firestore not initialized');
      await addDoc(collection(db, 'contacts'), {
        name,
        business,
        email,
        phone,
        message,
        createdAt: Timestamp.now(),
      });
      setStatus({ type: 'success', text: 'Message sent — we will get back to you shortly.' });
      setName(''); setBusiness(''); setEmail(''); setPhone(''); setMessage('');
    } catch (err: any) {
      console.error('Contact form error:', err);
      setStatus({ type: 'error', text: err.message || 'Failed to send message' });
    } finally {
      setLoading(false);
    }
  };

  return (
    <Box sx={{ minHeight: '80vh', py: 8 }}>
      <Container maxWidth="sm">
        <Box sx={{ display: 'flex', alignItems: 'center', mb: 3, gap: 2 }}>
          <IconButton onClick={() => navigate(-1)} sx={{ color: '#0f4e9d' }}>
            <ArrowBack />
          </IconButton>
          <IconButton onClick={() => navigate('/')} sx={{ color: '#0f4e9d' }}>
            <Home />
          </IconButton>
          <Typography variant="h4" fontWeight={800}>Get in Touch</Typography>
        </Box>
        <Typography variant="body1" color="text.secondary" sx={{ mb: 4 }}>Have questions? Want to learn more about Adna for your business?</Typography>

        {status && <Alert severity={status.type} sx={{ mb: 3 }}>{status.text}</Alert>}

        <Box component="form" onSubmit={handleSubmit} sx={{ display: 'grid', gap: 2 }}>
          <TextField label="Full name" required value={name} onChange={(e) => setName(e.target.value)} />
          <TextField label="Business name" required value={business} onChange={(e) => setBusiness(e.target.value)} />
          <TextField label="Email" required type="email" value={email} onChange={(e) => setEmail(e.target.value)} />
          <TextField label="Phone" value={phone} onChange={(e) => setPhone(e.target.value)} />
          <TextField label="Message" required multiline minRows={4} value={message} onChange={(e) => setMessage(e.target.value)} />

          <Box sx={{ display: 'flex', gap: 2 }}>
            <Button type="submit" variant="contained" disabled={loading} sx={{ bgcolor: '#0f4e9d' }}>Send Message</Button>
            <Button variant="outlined" onClick={() => window.location.href = 'mailto:hello@adna.ng'}>Email Us</Button>
          </Box>
        </Box>

        <Box sx={{ mt: 4 }}>
          <Typography variant="h6" fontWeight={700}>Business Hours</Typography>
          <Typography variant="body2" color="text.secondary">Monday - Friday, 9 AM - 6 PM WAT</Typography>
        </Box>
      </Container>
    </Box>
  );
};

export default ContactPage;
