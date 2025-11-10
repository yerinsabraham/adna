import React, { useEffect, useState } from 'react';
import {
  Box,
  Container,
  Typography,
  Paper,
  TextField,
  Button,
  Grid,
  MenuItem,
  Card,
  CardContent,
} from '@mui/material';
import DashboardLayout from '../components/DashboardLayout';
import { useAuth } from '../contexts/AuthContext';
import { createPaymentLink, getPayments } from '../services/firebase';
import toast from 'react-hot-toast';

const PaymentsPage: React.FC = () => {
  const { merchant } = useAuth();
  const [title, setTitle] = useState('');
  const [amount, setAmount] = useState<number | ''>('');
  const [currency, setCurrency] = useState('NGN');
  const [description, setDescription] = useState('');
  const [creating, setCreating] = useState(false);
  const [link, setLink] = useState<string | null>(null);
  const [list, setList] = useState<any[]>([]);

  useEffect(() => {
    if (!merchant) return;
    loadList();
  }, [merchant]);

  const loadList = async () => {
    if (!merchant) return;
    try {
      const items = await getPayments(merchant.id);
      setList(items as any[]);
    } catch (err) {
      console.error(err);
      toast.error('Failed to load payment links');
    }
  };

  const handleCreate = async () => {
    if (!merchant) return;
    if (!title || !amount) {
      toast.error('Provide title and amount');
      return;
    }
    try {
      setCreating(true);
      const path = await createPaymentLink(merchant.id, { title, description, currency, amount: Number(amount) });
      const fullLink = window.location.origin + path;
      setLink(fullLink);
      toast.success('Payment link created');
      // refresh list
      await loadList();
    } catch (err) {
      console.error(err);
      toast.error('Failed to create payment link');
    } finally {
      setCreating(false);
    }
  };

  return (
    <DashboardLayout>
      <Container maxWidth="md">
        <Box sx={{ mb: 4 }}>
          <Typography variant="h4">Payments</Typography>
          <Typography variant="body2" color="text.secondary">Create payment links and share with customers.</Typography>
        </Box>

        <Paper sx={{ p: 3, mb: 4 }}>
          <Grid container spacing={2}>
            <Grid item xs={12} sm={6}>
              <TextField fullWidth label="Title" value={title} onChange={(e) => setTitle(e.target.value)} />
            </Grid>
            <Grid item xs={12} sm={6}>
              <TextField fullWidth label="Amount" type="number" value={amount} onChange={(e) => setAmount(e.target.value === '' ? '' : Number(e.target.value))} />
            </Grid>
            <Grid item xs={12} sm={6}>
              <TextField select label="Currency" value={currency} onChange={(e) => setCurrency(e.target.value)} fullWidth>
                <MenuItem value="NGN">NGN</MenuItem>
                <MenuItem value="USD">USD</MenuItem>
                <MenuItem value="BTC">BTC</MenuItem>
                <MenuItem value="USDT">USDT</MenuItem>
                <MenuItem value="USDC">USDC</MenuItem>
              </TextField>
            </Grid>
            <Grid item xs={12}>
              <TextField fullWidth label="Description" multiline rows={2} value={description} onChange={(e) => setDescription(e.target.value)} />
            </Grid>
            <Grid item xs={12} sx={{ display: 'flex', gap: 2 }}>
              <Button variant="contained" onClick={handleCreate} disabled={creating}>{creating ? 'Creating...' : 'Create Payment Link'}</Button>
              {link && (
                <Button variant="outlined" component="a" href={link} target="_blank">Open Link</Button>
              )}
            </Grid>
          </Grid>
        </Paper>

        {link && (
          <Card sx={{ mb: 4 }}>
            <CardContent>
              <Typography variant="subtitle1">Payment Link</Typography>
              <Typography variant="body2" sx={{ wordBreak: 'break-all' }}>{link}</Typography>
              <Box sx={{ mt: 2 }}>
                <img src={`https://chart.googleapis.com/chart?cht=qr&chs=300x300&chl=${encodeURIComponent(link)}`} alt="QR code" />
              </Box>
            </CardContent>
          </Card>
        )}

        <Box>
          <Typography variant="h6" sx={{ mb: 2 }}>Your Links</Typography>
          {list.length === 0 ? (
            <Typography variant="body2" color="text.secondary">No payment links yet.</Typography>
          ) : (
            <Grid container spacing={2}>
              {list.map(item => (
                <Grid item xs={12} sm={6} key={item.id}>
                  <Card>
                    <CardContent>
                      <Typography variant="subtitle1">{item.title}</Typography>
                      <Typography variant="body2" color="text.secondary">{item.currency} {item.amount}</Typography>
                      <Button size="small" sx={{ mt: 1 }} component="a" href={`${window.location.origin}/pay/${item.id}`} target="_blank">Open</Button>
                    </CardContent>
                  </Card>
                </Grid>
              ))}
            </Grid>
          )}
        </Box>
      </Container>
    </DashboardLayout>
  );
};

export default PaymentsPage;
 
