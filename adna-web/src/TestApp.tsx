import { Box, Typography, Container, Paper } from '@mui/material';
import { ThemeProvider, createTheme, CssBaseline } from '@mui/material';

const theme = createTheme({
  palette: {
    mode: 'light',
    primary: {
      main: '#6C63FF',
    },
  },
});

function TestApp() {
  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <Container maxWidth="md">
        <Box sx={{ mt: 8, textAlign: 'center' }}>
          <Paper sx={{ p: 6 }}>
            <Typography variant="h3" gutterBottom>
              🎉 Adna Web App
            </Typography>
            <Typography variant="h6" color="text.secondary" gutterBottom>
              React + TypeScript + MUI Working!
            </Typography>
            <Typography variant="body1" sx={{ mt: 3 }}>
              Firebase Config Loaded ✅
            </Typography>
            <Typography variant="body2" color="text.secondary" sx={{ mt: 1 }}>
              If you see this, the app is rendering correctly.
            </Typography>
          </Paper>
        </Box>
      </Container>
    </ThemeProvider>
  );
}

export default TestApp;
