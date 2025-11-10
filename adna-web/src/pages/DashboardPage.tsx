import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Box,
  Grid,
  Card,
  CardContent,
  Typography,
  Button,
  LinearProgress,
  Alert,
} from '@mui/material';
import {
  TrendingUp,
  Receipt,
  AttachMoney,
  Assessment,
  ArrowForward,
  CheckCircle,
  Pending,
} from '@mui/icons-material';
import DashboardLayout from '../components/DashboardLayout';
import { useAuth } from '../contexts/AuthContext';
import { getMerchantStats } from '../services/firebase';
import LoadingSpinner from '../components/LoadingSpinner';
import toast from 'react-hot-toast';

const DashboardPage: React.FC = () => {
  const { merchant, user, refreshMerchant } = useAuth();
  const navigate = useNavigate();
  const [loading, setLoading] = useState(true);
  const [statsLoading, setStatsLoading] = useState(false);
  const [stats, setStats] = useState({
    totalVolume: 0,
    totalTransactions: 0,
    successRate: 0,
    monthVolume: 0,
  });

  useEffect(() => {
    const init = async () => {
      try {
        await refreshMerchant();
      } catch (error) {
        console.error('Error loading merchant:', error);
      } finally {
        setLoading(false);
      }
    };
    init();
  }, []);

  useEffect(() => {
    const isApproved = !!(
      merchant && (
        (merchant.kycStatus && ['approved', 'active', 'verified', 'complete'].includes((merchant.kycStatus as string).toLowerCase())) ||
        (merchant as any).onboarded === true ||
        merchant.isActive === true
      )
    );

    if (isApproved) {
      loadStats();
    }
  }, [merchant]);

  const loadStats = async () => {
    if (!merchant) return;
    
    try {
      setStatsLoading(true);
      const merchantStats = await getMerchantStats(merchant.id);
      setStats({
        totalVolume: merchantStats.totalVolume,
        totalTransactions: merchantStats.totalTransactions,
        successRate: merchantStats.successRate,
        monthVolume: merchantStats.monthVolume,
      });
    } catch (error) {
      console.error('Error loading stats:', error);
      toast.error('Failed to load dashboard statistics');
    } finally {
      setStatsLoading(false);
    }
  };

  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat('en-NG', {
      style: 'currency',
      currency: 'NGN',
    }).format(amount);
  };

  if (loading) {
    return (
      <DashboardLayout>
        <LoadingSpinner message="Loading dashboard..." />
      </DashboardLayout>
    );
  }

  // Check if merchant needs to complete onboarding
  const needsOnboarding = !merchant || (((merchant as any).onboarded !== true) && (!(merchant.kycStatus) || (merchant.kycStatus as string).toLowerCase() === 'incomplete'));

  if (needsOnboarding) {
    return (
      <DashboardLayout>
        <Box sx={{ maxWidth: 800, mx: 'auto', mt: 4 }}>
          <Alert severity="info" sx={{ mb: 3 }}>
            Welcome to Adna! Please complete your merchant onboarding to start accepting payments.
          </Alert>
          <Card>
            <CardContent sx={{ p: 4, textAlign: 'center' }}>
              <Pending sx={{ fontSize: 64, color: 'primary.main', mb: 2 }} />
              <Typography variant="h5" gutterBottom>
                Complete Your Onboarding
              </Typography>
              <Typography variant="body1" color="text.secondary" paragraph>
                Set up your business profile and complete KYC verification to start accepting payments.
              </Typography>
              <Button
                variant="contained"
                size="large"
                endIcon={<ArrowForward />}
                onClick={() => navigate('/onboarding')}
              >
                Start Onboarding
              </Button>
            </CardContent>
          </Card>
        </Box>
      </DashboardLayout>
    );
  }

  // Check if merchant is pending approval
  if (merchant.kycStatus === 'pending') {
    return (
      <DashboardLayout>
        <Box sx={{ maxWidth: 800, mx: 'auto', mt: 4 }}>
          <Alert severity="warning" sx={{ mb: 3 }}>
            Your account is under review. You'll be notified once approved.
          </Alert>
          <Card>
            <CardContent sx={{ p: 4, textAlign: 'center' }}>
              <Pending sx={{ fontSize: 64, color: 'warning.main', mb: 2 }} />
              <Typography variant="h5" gutterBottom>
                Application Under Review
              </Typography>
              <Typography variant="body1" color="text.secondary" paragraph>
                We're reviewing your KYC documents. This usually takes 1-2 business days.
              </Typography>
              <LinearProgress sx={{ my: 3 }} />
              <Typography variant="caption" color="text.secondary">
                You'll receive an email notification once your account is approved
              </Typography>
            </CardContent>
          </Card>
        </Box>
      </DashboardLayout>
    );
  }

  // Check if merchant was rejected
  if (merchant.kycStatus === 'rejected') {
    return (
      <DashboardLayout>
        <Box sx={{ maxWidth: 800, mx: 'auto', mt: 4 }}>
          <Alert severity="error" sx={{ mb: 3 }}>
            Your application was not approved. Please review the reason below and resubmit.
          </Alert>
          <Card>
            <CardContent sx={{ p: 4 }}>
              <Typography variant="h6" gutterBottom>
                Rejection Reason:
              </Typography>
              <Typography variant="body1" color="text.secondary" paragraph>
                {merchant.rejectionReason || 'Please contact support for details.'}
              </Typography>
              <Button
                variant="contained"
                onClick={() => navigate('/settings')}
              >
                Update Information
              </Button>
            </CardContent>
          </Card>
        </Box>
      </DashboardLayout>
    );
  }

  // Approved merchant - show dashboard
  const statCards = [
    {
      title: 'Total Volume',
      value: statsLoading ? '...' : formatCurrency(stats.totalVolume),
      icon: <AttachMoney />,
      color: 'primary',
      change: stats.totalTransactions > 0 ? `${stats.totalTransactions} txns` : 'No transactions yet',
    },
    {
      title: 'Transactions',
      value: statsLoading ? '...' : stats.totalTransactions.toString(),
      icon: <Receipt />,
      color: 'success',
      change: stats.totalTransactions > 0 ? 'All time' : 'Start accepting payments',
    },
    {
      title: 'Success Rate',
      value: statsLoading ? '...' : `${stats.successRate.toFixed(1)}%`,
      icon: <Assessment />,
      color: 'info',
      change: stats.totalTransactions > 0 ? 'Performance' : 'Not applicable',
    },
    {
      title: 'This Month',
      value: statsLoading ? '...' : formatCurrency(stats.monthVolume),
      icon: <TrendingUp />,
      color: 'warning',
      change: stats.monthVolume > 0 ? 'Current month' : 'No transactions',
    },
  ];

  return (
    <DashboardLayout>
      <Box>
        {/* Welcome Message */}
        <Box sx={{ mb: 4 }}>
          <Typography variant="h4" gutterBottom>
            Welcome back, {merchant.ownerName || user?.displayName}! 👋
          </Typography>
          <Typography variant="body1" color="text.secondary">
            Here's what's happening with your business today.
          </Typography>
        </Box>

        {/* KYC Status */}
        {merchant.kycStatus === 'approved' && (
          <Alert
            severity="success"
            icon={<CheckCircle />}
            sx={{ mb: 3 }}
          >
            Your account is verified and active. You can now accept payments.
          </Alert>
        )}

        {/* Stats Cards */}
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
                    <Typography variant="caption" color="text.secondary">
                      {stat.change}
                    </Typography>
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

        {/* Empty State Message */}
        {!statsLoading && stats.totalTransactions === 0 && (
          <Alert severity="info" sx={{ mb: 4 }}>
            <Typography variant="body2">
              <strong>Getting Started:</strong> Your dashboard is ready! Create your first payment link or start accepting transactions to see your stats here.
            </Typography>
          </Alert>
        )}

        {/* Quick Actions */}
        <Grid container spacing={3}>
          <Grid item xs={12} md={4}>
            <Card sx={{ height: '100%' }}>
              <CardContent>
                <Typography variant="h6" gutterBottom>
                  Create Payment Link
                </Typography>
                <Typography variant="body2" color="text.secondary" paragraph>
                  Generate a payment link to share with your customers
                </Typography>
                <Button
                  variant="contained"
                  fullWidth
                  onClick={() => navigate('/payments')}
                >
                  Create Link
                </Button>
              </CardContent>
            </Card>
          </Grid>
          <Grid item xs={12} md={4}>
            <Card sx={{ height: '100%' }}>
              <CardContent>
                <Typography variant="h6" gutterBottom>
                  View Transactions
                </Typography>
                <Typography variant="body2" color="text.secondary" paragraph>
                  Track all your payment transactions
                </Typography>
                <Button
                  variant="outlined"
                  fullWidth
                  onClick={() => navigate('/transactions')}
                >
                  View All
                </Button>
              </CardContent>
            </Card>
          </Grid>
          <Grid item xs={12} md={4}>
            <Card sx={{ height: '100%' }}>
              <CardContent>
                <Typography variant="h6" gutterBottom>
                  Billing & Reports
                </Typography>
                <Typography variant="body2" color="text.secondary" paragraph>
                  View settlements and download reports
                </Typography>
                <Button
                  variant="outlined"
                  fullWidth
                  onClick={() => navigate('/billing')}
                >
                  View Billing
                </Button>
              </CardContent>
            </Card>
          </Grid>
        </Grid>
      </Box>
    </DashboardLayout>
  );
};

export default DashboardPage;
