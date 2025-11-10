import React, { useEffect, useState } from 'react';
import { Box, Container, Typography, Paper, Grid, Card, CardContent, CircularProgress } from '@mui/material';
import { People, TrendingUp, Receipt, CheckCircle } from '@mui/icons-material';
import DashboardLayout from '../../components/DashboardLayout';
import { getPlatformStats } from '../../services/firebase';
import toast from 'react-hot-toast';

const AdminDashboardPage: React.FC = () => {
  const [loading, setLoading] = useState(true);
  const [stats, setStats] = useState({
    totalMerchants: 0,
    pendingMerchants: 0,
    totalTransactions: 0,
    totalVolume: 0,
  });

  useEffect(() => {
    loadStats();
  }, []);

  const loadStats = async () => {
    try {
      setLoading(true);
      const platformStats = await getPlatformStats();
      setStats({
        totalMerchants: platformStats.totalMerchants,
        pendingMerchants: platformStats.pendingMerchants,
        totalTransactions: platformStats.totalTransactions,
        totalVolume: platformStats.totalVolume,
      });
    } catch (error) {
      console.error('Error loading stats:', error);
      toast.error('Failed to load platform statistics');
    } finally {
      setLoading(false);
    }
  };

  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat('en-NG', {
      style: 'currency',
      currency: 'NGN',
    }).format(amount);
  };

  const statCards = [
    { 
      title: 'Total Merchants', 
      value: loading ? '...' : stats.totalMerchants.toString(), 
      icon: <People />, 
      color: 'primary' 
    },
    { 
      title: 'Pending Approval', 
      value: loading ? '...' : stats.pendingMerchants.toString(), 
      icon: <CheckCircle />, 
      color: 'warning' 
    },
    { 
      title: 'Total Transactions', 
      value: loading ? '...' : stats.totalTransactions.toString(), 
      icon: <Receipt />, 
      color: 'success' 
    },
    { 
      title: 'Platform Volume', 
      value: loading ? '...' : formatCurrency(stats.totalVolume), 
      icon: <TrendingUp />, 
      color: 'info' 
    },
  ];

  return (
    <DashboardLayout>
      <Container maxWidth="lg">
        <Box sx={{ mb: 4 }}>
          <Typography variant="h4" gutterBottom>
            Admin Dashboard
          </Typography>
          <Typography variant="body1" color="text.secondary">
            Platform overview and merchant management
          </Typography>
        </Box>

        {loading ? (
          <Box sx={{ display: 'flex', justifyContent: 'center', py: 8 }}>
            <CircularProgress />
          </Box>
        ) : (
          <>
            <Grid container spacing={3} sx={{ mb: 4 }}>
              {statCards.map((stat) => (
                <Grid item xs={12} sm={6} md={3} key={stat.title}>
                  <Card>
                    <CardContent>
                      <Box sx={{ display: 'flex', alignItems: 'center', mb: 2 }}>
                        <Box
                          sx={{
                            bgcolor: `${stat.color}.light`,
                            color: `${stat.color}.main`,
                            p: 1,
                            borderRadius: 2,
                            mr: 2,
                          }}
                        >
                          {stat.icon}
                        </Box>
                      </Box>
                      <Typography variant="h4" gutterBottom>
                        {stat.value}
                      </Typography>
                      <Typography variant="body2" color="text.secondary">
                        {stat.title}
                      </Typography>
                    </CardContent>
                  </Card>
                </Grid>
              ))}
            </Grid>

            <Paper sx={{ p: 4 }}>
              <Typography variant="h6" gutterBottom>
                Quick Actions
              </Typography>
              <Typography variant="body1" color="text.secondary">
                {stats.pendingMerchants > 0 
                  ? `You have ${stats.pendingMerchants} merchant${stats.pendingMerchants === 1 ? '' : 's'} pending approval. Go to Merchants → Pending to review.`
                  : 'No pending merchant approvals at this time.'}
              </Typography>
              {stats.totalTransactions === 0 && (
                <Typography variant="body2" color="text.secondary" sx={{ mt: 2 }}>
                  No transactions yet. Transactions will appear here once merchants start processing payments.
                </Typography>
              )}
            </Paper>
          </>
        )}
      </Container>
    </DashboardLayout>
  );
};

export default AdminDashboardPage;
