import { CssBaseline, Box, Typography, Container } from '@mui/material';

function SimpleApp() {
  console.log('SimpleApp rendering');
  
  return (
    <>
      <CssBaseline />
      <Container maxWidth="md">
        <Box
          sx={{
            minHeight: '100vh',
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            justifyContent: 'center',
            gap: 3,
          }}
        >
          <Typography variant="h3" component="h1" gutterBottom>
            Adna Web Platform
          </Typography>
          <Typography variant="h6" color="text.secondary">
            React is working ✅
          </Typography>
          <Typography variant="body1" color="text.secondary">
            Material-UI is working ✅
          </Typography>
          <Typography variant="body2" sx={{ mt: 2, p: 2, bgcolor: 'success.light', borderRadius: 1 }}>
            If you see this, the basic app structure is working correctly
          </Typography>
        </Box>
      </Container>
    </>
  );
}

export default SimpleApp;
