import React from 'react';
import { Box, Container, Typography, Paper } from '@mui/material';
import DashboardLayout from '../components/DashboardLayout';

const OnboardingPage: React.FC = () => {
  return (
    <DashboardLayout>
      <Container maxWidth="lg">
        <Box sx={{ mb: 4 }}>
          <Typography variant="h4" gutterBottom>
            Merchant Onboarding
          </Typography>
          <Typography variant="body1" color="text.secondary">
            Complete your business registration and KYC verification
          </Typography>
        </Box>
        <Paper sx={{ p: 4 }}>
          <Typography variant="body1">
            Onboarding form will be implemented here with multi-step process
          </Typography>
        </Paper>
      </Container>
    </DashboardLayout>
  );
};

export default OnboardingPage;
