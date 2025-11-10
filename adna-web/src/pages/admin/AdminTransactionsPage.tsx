import React from 'react';
import { Box, Container, Typography, Paper } from '@mui/material';
import DashboardLayout from '../../components/DashboardLayout';

const AdminTransactionsPage: React.FC = () => {
  return (
    <DashboardLayout>
      <Container maxWidth="lg">
        <Box sx={{ mb: 4 }}>
          <Typography variant="h4" gutterBottom>
            Platform Transactions
          </Typography>
          <Typography variant="body1" color="text.secondary">
            Monitor all transactions across the platform
          </Typography>
        </Box>
        <Paper sx={{ p: 4 }}>
          <Typography variant="body1">
            Platform-wide transaction monitoring and analytics will be implemented here
          </Typography>
        </Paper>
      </Container>
    </DashboardLayout>
  );
};

export default AdminTransactionsPage;
