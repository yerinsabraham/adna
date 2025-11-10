import React from 'react';
import { Box, Container, Typography, Paper } from '@mui/material';
import DashboardLayout from '../components/DashboardLayout';

const BillingPage: React.FC = () => {
  return (
    <DashboardLayout>
      <Container maxWidth="lg">
        <Box sx={{ mb: 4 }}>
          <Typography variant="h4" gutterBottom>
            Billing & Settlements
          </Typography>
          <Typography variant="body1" color="text.secondary">
            Track settlements, view invoices, and download reports
          </Typography>
        </Box>
        <Paper sx={{ p: 4 }}>
          <Typography variant="body1">
            Billing, settlement tracking, and report generation will be implemented here
          </Typography>
        </Paper>
      </Container>
    </DashboardLayout>
  );
};

export default BillingPage;
