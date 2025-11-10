import React from 'react';
import { Navigate } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import LoadingSpinner from './LoadingSpinner';
import { Box, Typography, Button } from '@mui/material';
import { Warning } from '@mui/icons-material';

interface AdminRouteProps {
  children: React.ReactNode;
}

const AdminRoute: React.FC<AdminRouteProps> = ({ children }) => {
  const { user, isAdmin, loading } = useAuth();

  if (loading) {
    return <LoadingSpinner fullScreen message="Checking admin access..." />;
  }

  if (!user) {
    return <Navigate to="/login" replace />;
  }

  if (!isAdmin) {
    return (
      <Box
        sx={{
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          justifyContent: 'center',
          minHeight: '100vh',
          gap: 3,
          px: 2,
        }}
      >
        <Warning sx={{ fontSize: 64, color: 'error.main' }} />
        <Typography variant="h4" gutterBottom>
          Access Denied
        </Typography>
        <Typography variant="body1" color="text.secondary" textAlign="center">
          You don't have permission to access the admin panel.
        </Typography>
        <Button
          variant="contained"
          onClick={() => window.location.href = '/'}
        >
          Go to Dashboard
        </Button>
      </Box>
    );
  }

  return <>{children}</>;
};

export default AdminRoute;
