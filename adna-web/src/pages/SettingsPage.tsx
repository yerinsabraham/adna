import React from 'react';
import { Box, Container, Typography, Paper } from '@mui/material';
import DashboardLayout from '../components/DashboardLayout';

const SettingsPage: React.FC = () => {
  return (
    <DashboardLayout>
      <Container maxWidth="lg">
        <Box sx={{ mb: 4 }}>
          <Typography variant="h4" gutterBottom>
            Settings
          </Typography>
          <Typography variant="body1" color="text.secondary">
            Manage your account, business profile, and preferences
          </Typography>
        </Box>
        <Paper sx={{ p: 4 }}>
          <Typography variant="body1">
            Account settings, profile management, and configuration options will be implemented here
          </Typography>
        </Paper>
      </Container>
    </DashboardLayout>
  );
};

export default SettingsPage;
