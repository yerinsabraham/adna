import React, { useEffect, useState } from 'react';
import {
  Box,
  Container,
  Typography,
  Paper,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Chip,
  TextField,
  InputAdornment,
  CircularProgress,
  Alert,
} from '@mui/material';
import { Search } from '@mui/icons-material';
import DashboardLayout from '../components/DashboardLayout';
import { useAuth } from '../contexts/AuthContext';
import { getTransactions } from '../services/firebase';
import type { Transaction } from '../types';
import toast from 'react-hot-toast';

const TransactionsPage: React.FC = () => {
  const { merchant, loading: authLoading } = useAuth();
  const [transactions, setTransactions] = useState<Transaction[]>([]);
  const [filteredTransactions, setFilteredTransactions] = useState<Transaction[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState('');

  useEffect(() => {
    // Wait for auth to resolve; if auth finished and merchant is null stop showing spinner
    if (authLoading) return;

    if (merchant) {
      loadTransactions();
    } else {
      setLoading(false);
    }
  }, [merchant, authLoading]);

  useEffect(() => {
    if (searchQuery) {
      const filtered = transactions.filter(
        (txn) =>
          txn.reference.toLowerCase().includes(searchQuery.toLowerCase()) ||
          txn.customerEmail?.toLowerCase().includes(searchQuery.toLowerCase()) ||
          txn.customerName?.toLowerCase().includes(searchQuery.toLowerCase())
      );
      setFilteredTransactions(filtered);
    } else {
      setFilteredTransactions(transactions);
    }
  }, [searchQuery, transactions]);

  const loadTransactions = async () => {
    if (!merchant) return;

    try {
      setLoading(true);
      const txns = await getTransactions(merchant.id);
      setTransactions(txns);
      setFilteredTransactions(txns);
    } catch (error) {
      console.error('Error loading transactions:', error);
      toast.error('Failed to load transactions');
    } finally {
      setLoading(false);
    }
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'completed':
        return 'success';
      case 'pending':
        return 'warning';
      case 'failed':
        return 'error';
      case 'cancelled':
        return 'default';
      default:
        return 'default';
    }
  };

  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat('en-NG', {
      style: 'currency',
      currency: 'NGN',
    }).format(amount);
  };

  const formatDate = (date: Date) => {
    return new Intl.DateTimeFormat('en-NG', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
    }).format(date);
  };

  return (
    <DashboardLayout>
      <Container maxWidth="lg">
        <Box sx={{ mb: 4 }}>
          <Typography variant="h4" gutterBottom>
            Transactions
          </Typography>
          <Typography variant="body1" color="text.secondary">
            View and manage all your payment transactions
          </Typography>
        </Box>

        <Paper sx={{ p: 3, mb: 3 }}>
          <TextField
            fullWidth
            placeholder="Search by reference, customer email, or name..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            InputProps={{
              startAdornment: (
                <InputAdornment position="start">
                  <Search />
                </InputAdornment>
              ),
            }}
          />
        </Paper>

        {loading ? (
          <Box sx={{ display: 'flex', justifyContent: 'center', py: 8 }}>
            <CircularProgress />
          </Box>
        ) : filteredTransactions.length === 0 ? (
          <Alert severity="info">
            {searchQuery
              ? 'No transactions found matching your search.'
              : 'No transactions yet. Start accepting payments to see them here.'}
          </Alert>
        ) : (
          <TableContainer component={Paper}>
            <Table>
              <TableHead>
                <TableRow>
                  <TableCell>Reference</TableCell>
                  <TableCell>Customer</TableCell>
                  <TableCell>Amount</TableCell>
                  <TableCell>Method</TableCell>
                  <TableCell>Status</TableCell>
                  <TableCell>Date</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {filteredTransactions.map((transaction) => (
                  <TableRow key={transaction.id} hover>
                    <TableCell>
                      <Typography variant="body2" fontWeight="medium">
                        {transaction.reference}
                      </Typography>
                      {transaction.description && (
                        <Typography variant="caption" color="text.secondary">
                          {transaction.description}
                        </Typography>
                      )}
                    </TableCell>
                    <TableCell>
                      <Typography variant="body2">
                        {transaction.customerName || transaction.customerEmail || 'N/A'}
                      </Typography>
                      {transaction.customerEmail && transaction.customerName && (
                        <Typography variant="caption" color="text.secondary">
                          {transaction.customerEmail}
                        </Typography>
                      )}
                    </TableCell>
                    <TableCell>
                      <Typography variant="body2" fontWeight="medium">
                        {formatCurrency(transaction.amount)}
                      </Typography>
                      <Typography variant="caption" color="text.secondary">
                        Fee: {formatCurrency(transaction.fee)}
                      </Typography>
                    </TableCell>
                    <TableCell>
                      <Chip
                        label={transaction.paymentMethod.replace('_', ' ').toUpperCase()}
                        size="small"
                        variant="outlined"
                      />
                    </TableCell>
                    <TableCell>
                      <Chip
                        label={transaction.status.toUpperCase()}
                        color={getStatusColor(transaction.status)}
                        size="small"
                      />
                    </TableCell>
                    <TableCell>
                      <Typography variant="body2">
                        {formatDate(transaction.createdAt)}
                      </Typography>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </TableContainer>
        )}
      </Container>
    </DashboardLayout>
  );
};

export default TransactionsPage;
