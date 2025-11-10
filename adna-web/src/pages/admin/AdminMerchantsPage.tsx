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
  Button,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
  Stack,
  Alert,
  CircularProgress,
  Tabs,
  Tab,
  Card,
  CardContent,
  Grid,
  Divider,
} from '@mui/material';
import {
  CheckCircle,
  Cancel,
  Visibility,
  Business,
  Person,
  Email,
  AccountBalance,
} from '@mui/icons-material';
import DashboardLayout from '../../components/DashboardLayout';
import { getPendingMerchants, getAllMerchants, approveMerchant, rejectMerchant } from '../../services/firebase';
import type { Merchant } from '../../types';
import toast from 'react-hot-toast';

const AdminMerchantsPage: React.FC = () => {
  const [tabValue, setTabValue] = useState(0);
  const [pendingMerchants, setPendingMerchants] = useState<Merchant[]>([]);
  const [allMerchants, setAllMerchants] = useState<Merchant[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedMerchant, setSelectedMerchant] = useState<Merchant | null>(null);
  const [detailsOpen, setDetailsOpen] = useState(false);
  const [rejectDialogOpen, setRejectDialogOpen] = useState(false);
  const [rejectionReason, setRejectionReason] = useState('');
  const [actionLoading, setActionLoading] = useState(false);

  useEffect(() => {
    loadMerchants();
  }, []);

  const loadMerchants = async () => {
    try {
      setLoading(true);
      const [pending, all] = await Promise.all([
        getPendingMerchants(),
        getAllMerchants(),
      ]);
      setPendingMerchants(pending);
      setAllMerchants(all);
    } catch (error) {
      console.error('Error loading merchants:', error);
      toast.error('Failed to load merchants');
    } finally {
      setLoading(false);
    }
  };

  const handleViewDetails = (merchant: Merchant) => {
    setSelectedMerchant(merchant);
    setDetailsOpen(true);
  };

  const handleApprove = async (merchantId: string) => {
    if (!confirm('Are you sure you want to approve this merchant?')) return;

    try {
      setActionLoading(true);
      await approveMerchant(merchantId, 'standard', {
        dailyLimit: 1000000,
        monthlyLimit: 30000000,
      });
      toast.success('Merchant approved successfully!');
      setDetailsOpen(false);
      await loadMerchants();
    } catch (error) {
      console.error('Error approving merchant:', error);
      toast.error('Failed to approve merchant');
    } finally {
      setActionLoading(false);
    }
  };

  const handleRejectClick = (merchant: Merchant) => {
    setSelectedMerchant(merchant);
    setRejectionReason('');
    setRejectDialogOpen(true);
  };

  const handleRejectConfirm = async () => {
    if (!selectedMerchant) return;
    if (!rejectionReason.trim()) {
      toast.error('Please provide a rejection reason');
      return;
    }

    try {
      setActionLoading(true);
      await rejectMerchant(selectedMerchant.id, rejectionReason);
      toast.success('Merchant application rejected');
      setRejectDialogOpen(false);
      setDetailsOpen(false);
      await loadMerchants();
    } catch (error) {
      console.error('Error rejecting merchant:', error);
      toast.error('Failed to reject merchant');
    } finally {
      setActionLoading(false);
    }
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'approved':
        return 'success';
      case 'pending':
        return 'warning';
      case 'rejected':
        return 'error';
      default:
        return 'default';
    }
  };

  const formatDate = (timestamp: any) => {
    if (!timestamp) return 'N/A';
    const date = timestamp.toDate ? timestamp.toDate() : new Date(timestamp);
    return date.toLocaleDateString('en-US', { 
      year: 'numeric', 
      month: 'short', 
      day: 'numeric' 
    });
  };

  const merchantsToDisplay = tabValue === 0 ? pendingMerchants : allMerchants;

  return (
    <DashboardLayout>
      <Container maxWidth="xl">
        <Box sx={{ mb: 4 }}>
          <Typography variant="h4" gutterBottom fontWeight={700}>
            Merchant Management
          </Typography>
          <Typography variant="body1" color="text.secondary">
            Review, approve, and manage merchant accounts
          </Typography>
        </Box>

        {/* Stats Cards */}
        <Grid container spacing={3} sx={{ mb: 4 }}>
          <Grid item xs={12} sm={4}>
            <Card>
              <CardContent>
                <Typography color="text.secondary" gutterBottom>
                  Pending Approval
                </Typography>
                <Typography variant="h3" color="warning.main">
                  {pendingMerchants.length}
                </Typography>
              </CardContent>
            </Card>
          </Grid>
          <Grid item xs={12} sm={4}>
            <Card>
              <CardContent>
                <Typography color="text.secondary" gutterBottom>
                  Total Merchants
                </Typography>
                <Typography variant="h3" color="primary.main">
                  {allMerchants.length}
                </Typography>
              </CardContent>
            </Card>
          </Grid>
          <Grid item xs={12} sm={4}>
            <Card>
              <CardContent>
                <Typography color="text.secondary" gutterBottom>
                  Active Merchants
                </Typography>
                <Typography variant="h3" color="success.main">
                  {allMerchants.filter(m => m.isActive).length}
                </Typography>
              </CardContent>
            </Card>
          </Grid>
        </Grid>

        {/* Tabs */}
        <Paper sx={{ mb: 3 }}>
          <Tabs value={tabValue} onChange={(_, v) => setTabValue(v)}>
            <Tab label={`Pending (${pendingMerchants.length})`} />
            <Tab label={`All Merchants (${allMerchants.length})`} />
          </Tabs>
        </Paper>

        {/* Merchants Table */}
        {loading ? (
          <Box sx={{ display: 'flex', justifyContent: 'center', py: 8 }}>
            <CircularProgress />
          </Box>
        ) : merchantsToDisplay.length === 0 ? (
          <Alert severity="info">
            {tabValue === 0 
              ? 'No pending merchant applications' 
              : 'No merchants found'}
          </Alert>
        ) : (
          <TableContainer component={Paper}>
            <Table>
              <TableHead>
                <TableRow>
                  <TableCell><strong>Business Name</strong></TableCell>
                  <TableCell><strong>Owner</strong></TableCell>
                  <TableCell><strong>Email</strong></TableCell>
                  <TableCell><strong>Phone</strong></TableCell>
                  <TableCell><strong>Status</strong></TableCell>
                  <TableCell><strong>Submitted</strong></TableCell>
                  <TableCell align="right"><strong>Actions</strong></TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {merchantsToDisplay.map((merchant) => (
                  <TableRow key={merchant.id} hover>
                    <TableCell>{merchant.businessName || 'N/A'}</TableCell>
                    <TableCell>{merchant.ownerName || 'N/A'}</TableCell>
                    <TableCell>{merchant.email}</TableCell>
                    <TableCell>{merchant.phoneNumber || 'N/A'}</TableCell>
                    <TableCell>
                      <Chip
                        label={merchant.kycStatus?.toUpperCase()}
                        color={getStatusColor(merchant.kycStatus || '')}
                        size="small"
                      />
                    </TableCell>
                    <TableCell>{formatDate(merchant.createdAt)}</TableCell>
                    <TableCell align="right">
                      <Stack direction="row" spacing={1} justifyContent="flex-end">
                        <Button
                          size="small"
                          startIcon={<Visibility />}
                          onClick={() => handleViewDetails(merchant)}
                        >
                          View
                        </Button>
                        {merchant.kycStatus === 'pending' && (
                          <>
                            <Button
                              size="small"
                              variant="contained"
                              color="success"
                              startIcon={<CheckCircle />}
                              onClick={() => handleApprove(merchant.id)}
                            >
                              Approve
                            </Button>
                            <Button
                              size="small"
                              variant="outlined"
                              color="error"
                              startIcon={<Cancel />}
                              onClick={() => handleRejectClick(merchant)}
                            >
                              Reject
                            </Button>
                          </>
                        )}
                      </Stack>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </TableContainer>
        )}

        {/* Merchant Details Dialog */}
        <Dialog
          open={detailsOpen}
          onClose={() => setDetailsOpen(false)}
          maxWidth="md"
          fullWidth
        >
          <DialogTitle>
            Merchant Application Details
          </DialogTitle>
          <DialogContent>
            {selectedMerchant && (
              <Stack spacing={3} sx={{ mt: 2 }}>
                {/* Business Information */}
                <Box>
                  <Typography variant="h6" gutterBottom sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                    <Business /> Business Information
                  </Typography>
                  <Divider sx={{ mb: 2 }} />
                  <Grid container spacing={2}>
                    <Grid item xs={12} sm={6}>
                      <Typography variant="caption" color="text.secondary">Business Name</Typography>
                      <Typography variant="body1">{selectedMerchant.businessName || 'N/A'}</Typography>
                    </Grid>
                    <Grid item xs={12} sm={6}>
                      <Typography variant="caption" color="text.secondary">Registration Type</Typography>
                      <Typography variant="body1">{selectedMerchant.registrationType || 'N/A'}</Typography>
                    </Grid>
                    <Grid item xs={12} sm={6}>
                      <Typography variant="caption" color="text.secondary">CAC Number</Typography>
                      <Typography variant="body1">{selectedMerchant.cacNumber || 'N/A'}</Typography>
                    </Grid>
                    <Grid item xs={12} sm={6}>
                      <Typography variant="caption" color="text.secondary">TIN</Typography>
                      <Typography variant="body1">{selectedMerchant.tin || 'N/A'}</Typography>
                    </Grid>
                    <Grid item xs={12}>
                      <Typography variant="caption" color="text.secondary">Business Address</Typography>
                      <Typography variant="body1">
                        {typeof selectedMerchant.businessAddress === 'string' 
                          ? selectedMerchant.businessAddress 
                          : selectedMerchant.businessAddress 
                            ? `${selectedMerchant.businessAddress.street}, ${selectedMerchant.businessAddress.city}, ${selectedMerchant.businessAddress.state}` 
                            : 'N/A'}
                      </Typography>
                    </Grid>
                  </Grid>
                </Box>

                {/* Owner Information */}
                <Box>
                  <Typography variant="h6" gutterBottom sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                    <Person /> Owner Information
                  </Typography>
                  <Divider sx={{ mb: 2 }} />
                  <Grid container spacing={2}>
                    <Grid item xs={12} sm={6}>
                      <Typography variant="caption" color="text.secondary">Full Name</Typography>
                      <Typography variant="body1">{selectedMerchant.ownerName || 'N/A'}</Typography>
                    </Grid>
                    <Grid item xs={12} sm={6}>
                      <Typography variant="caption" color="text.secondary">BVN</Typography>
                      <Typography variant="body1">{selectedMerchant.bvn || 'N/A'}</Typography>
                    </Grid>
                  </Grid>
                </Box>

                {/* Contact Information */}
                <Box>
                  <Typography variant="h6" gutterBottom sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                    <Email /> Contact Information
                  </Typography>
                  <Divider sx={{ mb: 2 }} />
                  <Grid container spacing={2}>
                    <Grid item xs={12} sm={6}>
                      <Typography variant="caption" color="text.secondary">Email</Typography>
                      <Typography variant="body1">{selectedMerchant.email}</Typography>
                    </Grid>
                    <Grid item xs={12} sm={6}>
                      <Typography variant="caption" color="text.secondary">Phone</Typography>
                      <Typography variant="body1">{selectedMerchant.phoneNumber || 'N/A'}</Typography>
                    </Grid>
                  </Grid>
                </Box>

                {/* Bank Information */}
                <Box>
                  <Typography variant="h6" gutterBottom sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                    <AccountBalance /> Bank Information
                  </Typography>
                  <Divider sx={{ mb: 2 }} />
                  <Grid container spacing={2}>
                    <Grid item xs={12} sm={6}>
                      <Typography variant="caption" color="text.secondary">Bank Name</Typography>
                      <Typography variant="body1">{selectedMerchant.bankName || 'N/A'}</Typography>
                    </Grid>
                    <Grid item xs={12} sm={6}>
                      <Typography variant="caption" color="text.secondary">Account Number</Typography>
                      <Typography variant="body1">{selectedMerchant.accountNumber || 'N/A'}</Typography>
                    </Grid>
                    <Grid item xs={12}>
                      <Typography variant="caption" color="text.secondary">Account Name</Typography>
                      <Typography variant="body1">{selectedMerchant.accountName || 'N/A'}</Typography>
                    </Grid>
                  </Grid>
                </Box>

                {/* Status */}
                <Box>
                  <Typography variant="caption" color="text.secondary">Application Status</Typography>
                  <Box sx={{ mt: 1 }}>
                    <Chip
                      label={selectedMerchant.kycStatus?.toUpperCase()}
                      color={getStatusColor(selectedMerchant.kycStatus || '')}
                    />
                  </Box>
                  {selectedMerchant.rejectionReason && (
                    <Alert severity="error" sx={{ mt: 2 }}>
                      <strong>Rejection Reason:</strong> {selectedMerchant.rejectionReason}
                    </Alert>
                  )}
                </Box>
              </Stack>
            )}
          </DialogContent>
          <DialogActions>
            {selectedMerchant?.kycStatus === 'pending' && (
              <>
                <Button
                  onClick={() => handleRejectClick(selectedMerchant)}
                  color="error"
                  disabled={actionLoading}
                >
                  Reject
                </Button>
                <Button
                  onClick={() => handleApprove(selectedMerchant.id)}
                  variant="contained"
                  color="success"
                  disabled={actionLoading}
                >
                  {actionLoading ? 'Processing...' : 'Approve'}
                </Button>
              </>
            )}
            <Button onClick={() => setDetailsOpen(false)}>Close</Button>
          </DialogActions>
        </Dialog>

        {/* Rejection Dialog */}
        <Dialog open={rejectDialogOpen} onClose={() => setRejectDialogOpen(false)}>
          <DialogTitle>Reject Merchant Application</DialogTitle>
          <DialogContent>
            <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
              Please provide a reason for rejecting this merchant application:
            </Typography>
            <TextField
              fullWidth
              multiline
              rows={4}
              label="Rejection Reason"
              value={rejectionReason}
              onChange={(e) => setRejectionReason(e.target.value)}
              placeholder="e.g., Incomplete documentation, Invalid BVN, etc."
            />
          </DialogContent>
          <DialogActions>
            <Button onClick={() => setRejectDialogOpen(false)} disabled={actionLoading}>
              Cancel
            </Button>
            <Button
              onClick={handleRejectConfirm}
              variant="contained"
              color="error"
              disabled={actionLoading}
            >
              {actionLoading ? 'Processing...' : 'Confirm Rejection'}
            </Button>
          </DialogActions>
        </Dialog>
      </Container>
    </DashboardLayout>
  );
};

export default AdminMerchantsPage;
