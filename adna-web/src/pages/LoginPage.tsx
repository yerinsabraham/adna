import { useEffect, useState } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import {
  Box,
  Container,
  Paper,
  Typography,
  Button,
  Stack,
  Alert,
  Grid,
  useTheme,
  useMediaQuery,
  TextField,
  InputAdornment,
  IconButton,
  Divider,
  Link,
} from '@mui/material';
import { 
  Warning, 
  Security, 
  Speed, 
  TrendingUp,
  AccountBalance,
  Visibility,
  VisibilityOff,
  Email,
  Lock,
  Person,
} from '@mui/icons-material';
import { useAuth } from '../contexts/AuthContext';
import { FIREBASE_ENABLED } from '../config/firebase';
import toast from 'react-hot-toast';

const LoginPage: React.FC = () => {
  const { user, signInWithGoogle } = useAuth();
  const navigate = useNavigate();
  const theme = useTheme();
  const isMobile = useMediaQuery(theme.breakpoints.down('md'));

  const [isRegister, setIsRegister] = useState(false);
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  
  const [formData, setFormData] = useState({
    fullName: '',
    email: '',
    password: '',
    confirmPassword: '',
  });

  useEffect(() => {
    if (user) {
      navigate('/dashboard', { replace: true });
    }
  }, [user, navigate]);

  // If navigation state requests register mode, open registration form
  const location = useLocation();
  useEffect(() => {
    if (location?.state && (location as any).state.register) {
      setIsRegister(true);
    }
  }, [location]);

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value,
    });
  };

  const handleEmailPasswordAuth = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!FIREBASE_ENABLED) {
      toast.error('Firebase not configured');
      return;
    }

    // Validation
    if (isRegister) {
      if (!formData.fullName.trim()) {
        toast.error('Please enter your full name');
        return;
      }
      if (formData.password !== formData.confirmPassword) {
        toast.error('Passwords do not match');
        return;
      }
      if (formData.password.length < 6) {
        toast.error('Password must be at least 6 characters');
        return;
      }
    }

    if (!formData.email.trim() || !formData.password.trim()) {
      toast.error('Please fill in all fields');
      return;
    }

    setLoading(true);
    try {
      if (isRegister) {
        // Register new user
        const { signUpWithEmail } = await import('../services/firebase');
        await signUpWithEmail(formData.email, formData.password, formData.fullName);
        toast.success('Account created successfully! Please complete your merchant profile.');
      } else {
        // Login existing user
        const { signInWithEmail } = await import('../services/firebase');
        await signInWithEmail(formData.email, formData.password);
        toast.success('Welcome back!');
      }
    } catch (error: any) {
      console.error('Auth error:', error);
      const errorMessage = error.message || 'Authentication failed';
      toast.error(errorMessage);
    } finally {
      setLoading(false);
    }
  };

  const handleGoogleSignIn = async () => {
    try {
      setLoading(true);
      await signInWithGoogle();
      toast.success('Signed in successfully!');
    } catch (error) {
      console.error('Login error:', error);
      toast.error('Failed to sign in with Google');
    } finally {
      setLoading(false);
    }
  };

  const toggleMode = () => {
    setIsRegister(!isRegister);
    setFormData({
      fullName: '',
      email: '',
      password: '',
      confirmPassword: '',
    });
  };

  return (
    <Box
      sx={{
        minHeight: '100vh',
        display: 'flex',
        background: 'linear-gradient(135deg, #0f4e9d 0%, #1a73e8 100%)',
      }}
    >
      <Grid container sx={{ flex: 1 }}>
        {/* Left Side - Branding (Hidden on mobile) */}
        {!isMobile && (
          <Grid
            item
            md={6}
            sx={{
              display: 'flex',
              flexDirection: 'column',
              justifyContent: 'center',
              alignItems: 'center',
              color: 'white',
              p: 8,
              position: 'relative',
              overflow: 'hidden',
              background: 'linear-gradient(135deg, #0a3d7a 0%, #0f4e9d 100%)', // Darker gradient for logo visibility
            }}
          >
            {/* Background Pattern */}
            <Box
              sx={{
                position: 'absolute',
                top: 0,
                left: 0,
                right: 0,
                bottom: 0,
                opacity: 0.08,
                backgroundImage: 'radial-gradient(circle, white 1px, transparent 1px)',
                backgroundSize: '50px 50px',
              }}
            />

            <Box sx={{ position: 'relative', zIndex: 1, maxWidth: 500 }}>
              {/* Logo with white background circle for visibility */}
              <Box
                sx={{
                  width: '140px',
                  height: '140px',
                  borderRadius: '50%',
                  bgcolor: 'white',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  mb: 4,
                  boxShadow: '0 8px 24px rgba(0,0,0,0.15)',
                }}
              >
                <img
                  src="/logo.png"
                  alt="Adna"
                  style={{
                    width: '100px',
                    height: '100px',
                    objectFit: 'contain',
                  }}
                />
              </Box>
              <Typography
                variant="h2"
                sx={{
                  fontWeight: 800,
                  mb: 3,
                  fontSize: { xs: '2.5rem', md: '3.5rem' },
                }}
              >
                Welcome to Adna
              </Typography>
              <Typography
                variant="h5"
                sx={{
                  mb: 6,
                  opacity: 0.95,
                  fontWeight: 400,
                  lineHeight: 1.6,
                }}
              >
                The complete payment gateway platform for modern businesses
              </Typography>

              {/* Features */}
              <Stack spacing={3}>
                {[
                  {
                    icon: <Speed sx={{ fontSize: 32 }} />,
                    title: 'Lightning Fast',
                    desc: 'Process transactions in real-time',
                  },
                  {
                    icon: <Security sx={{ fontSize: 32 }} />,
                    title: 'Bank-Level Security',
                    desc: 'Enterprise-grade encryption & compliance',
                  },
                  {
                    icon: <TrendingUp sx={{ fontSize: 32 }} />,
                    title: 'Powerful Analytics',
                    desc: 'Comprehensive insights & reporting',
                  },
                  {
                    icon: <AccountBalance sx={{ fontSize: 32 }} />,
                    title: 'Multi-Currency',
                    desc: 'Accept Naira & cryptocurrency payments',
                  },
                ].map((feature, index) => (
                  <Box key={index} sx={{ display: 'flex', gap: 2, alignItems: 'flex-start' }}>
                    <Box
                      sx={{
                        p: 1.5,
                        borderRadius: 2,
                        bgcolor: 'rgba(255, 255, 255, 0.15)',
                        backdropFilter: 'blur(10px)',
                      }}
                    >
                      {feature.icon}
                    </Box>
                    <Box>
                      <Typography variant="h6" sx={{ fontWeight: 600, mb: 0.5 }}>
                        {feature.title}
                      </Typography>
                      <Typography variant="body2" sx={{ opacity: 0.9 }}>
                        {feature.desc}
                      </Typography>
                    </Box>
                  </Box>
                ))}
              </Stack>
            </Box>
          </Grid>
        )}

        {/* Right Side - Login Form */}
        <Grid
          item
          xs={12}
          md={6}
          sx={{
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            p: { xs: 3, md: 8 },
            bgcolor: { xs: 'transparent', md: '#FAFAFA' },
          }}
        >
          <Container maxWidth="sm">
            <Paper
              elevation={isMobile ? 0 : 8}
              sx={{
                p: { xs: 4, md: 6 },
                borderRadius: 4,
                bgcolor: 'white',
                maxWidth: 480,
                mx: 'auto',
              }}
            >
              <Stack spacing={4} alignItems="center">
                {/* Logo for mobile */}
                {isMobile && (
                  <img
                    src="/logo.png"
                    alt="Adna Logo"
                    style={{
                      width: '100px',
                      height: '100px',
                      objectFit: 'contain',
                    }}
                  />
                )}

                {/* Header */}
                <Box textAlign="center" sx={{ width: '100%' }}>
                  <Typography
                    variant="h4"
                    sx={{
                      fontWeight: 700,
                      color: 'text.primary',
                      mb: 1,
                    }}
                  >
                    {isRegister ? 'Create your account' : 'Sign in to Adna'}
                  </Typography>
                  <Typography variant="body1" color="text.secondary">
                    {isRegister 
                      ? 'Start accepting payments in minutes' 
                      : 'Access your merchant dashboard'}
                  </Typography>
                </Box>

                {/* Firebase Warning */}
                {!FIREBASE_ENABLED && (
                  <Alert severity="warning" icon={<Warning />} sx={{ width: '100%' }}>
                    <Typography variant="caption" fontWeight={600}>
                      Firebase Not Configured
                    </Typography>
                    <Typography variant="caption" display="block">
                      Please update the `.env` file with your Firebase credentials.
                    </Typography>
                  </Alert>
                )}

                {/* Email/Password Form */}
                <Box component="form" onSubmit={handleEmailPasswordAuth} sx={{ width: '100%' }}>
                  <Stack spacing={2}>
                    {/* Full Name (Register only) */}
                    {isRegister && (
                      <TextField
                        fullWidth
                        size="small"
                        label="Full Name"
                        name="fullName"
                        value={formData.fullName}
                        onChange={handleInputChange}
                        placeholder="John Doe"
                        disabled={!FIREBASE_ENABLED || loading}
                        InputProps={{
                          startAdornment: (
                            <InputAdornment position="start">
                              <Person color="action" fontSize="small" />
                            </InputAdornment>
                          ),
                          sx: { fontSize: '0.95rem' }
                        }}
                        InputLabelProps={{
                          sx: { fontSize: '0.95rem' }
                        }}
                      />
                    )}

                    {/* Email */}
                    <TextField
                      fullWidth
                      size="small"
                      label="Email Address"
                      name="email"
                      type="email"
                      value={formData.email}
                      onChange={handleInputChange}
                      placeholder="you@example.com"
                      disabled={!FIREBASE_ENABLED || loading}
                      InputProps={{
                        startAdornment: (
                          <InputAdornment position="start">
                            <Email color="action" fontSize="small" />
                          </InputAdornment>
                        ),
                        sx: { fontSize: '0.95rem' }
                      }}
                      InputLabelProps={{
                        sx: { fontSize: '0.95rem' }
                      }}
                    />

                    {/* Password */}
                    <TextField
                      fullWidth
                      size="small"
                      label="Password"
                      name="password"
                      type={showPassword ? 'text' : 'password'}
                      value={formData.password}
                      onChange={handleInputChange}
                      placeholder="••••••••"
                      disabled={!FIREBASE_ENABLED || loading}
                      InputProps={{
                        startAdornment: (
                          <InputAdornment position="start">
                            <Lock color="action" fontSize="small" />
                          </InputAdornment>
                        ),
                        endAdornment: (
                          <InputAdornment position="end">
                            <IconButton
                              onClick={() => setShowPassword(!showPassword)}
                              edge="end"
                              size="small"
                            >
                              {showPassword ? <VisibilityOff fontSize="small" /> : <Visibility fontSize="small" />}
                            </IconButton>
                          </InputAdornment>
                        ),
                        sx: { fontSize: '0.95rem' }
                      }}
                      InputLabelProps={{
                        sx: { fontSize: '0.95rem' }
                      }}
                    />

                    {/* Confirm Password (Register only) */}
                    {isRegister && (
                      <TextField
                        fullWidth
                        size="small"
                        label="Confirm Password"
                        name="confirmPassword"
                        type={showPassword ? 'text' : 'password'}
                        value={formData.confirmPassword}
                        onChange={handleInputChange}
                        placeholder="••••••••"
                        disabled={!FIREBASE_ENABLED || loading}
                        InputProps={{
                          startAdornment: (
                            <InputAdornment position="start">
                              <Lock color="action" fontSize="small" />
                            </InputAdornment>
                          ),
                          sx: { fontSize: '0.95rem' }
                        }}
                        InputLabelProps={{
                          sx: { fontSize: '0.95rem' }
                        }}
                      />
                    )}

                    {/* Submit Button */}
                    <Button
                      type="submit"
                      variant="contained"
                      size="medium"
                      fullWidth
                      disabled={!FIREBASE_ENABLED || loading}
                      sx={{
                        py: 1.25,
                        fontSize: '0.95rem',
                        fontWeight: 600,
                        textTransform: 'none',
                        bgcolor: 'primary.main',
                        '&:hover': {
                          bgcolor: 'primary.dark',
                        },
                      }}
                    >
                      {loading ? 'Please wait...' : (isRegister ? 'Create Account' : 'Sign In')}
                    </Button>
                  </Stack>
                </Box>

                {/* Divider */}
                <Divider sx={{ width: '100%', my: 1 }}>
                  <Typography variant="body2" color="text.secondary">
                    OR
                  </Typography>
                </Divider>

                {/* Google Sign In Button */}
                <Button
                  variant="outlined"
                  size="medium"
                  fullWidth
                  onClick={handleGoogleSignIn}
                  disabled={!FIREBASE_ENABLED || loading}
                  sx={{
                    py: 1.25,
                    fontSize: '0.95rem',
                    fontWeight: 600,
                    color: '#000',
                    bgcolor: 'white',
                    border: '2px solid #DADCE0',
                    borderRadius: 2,
                    textTransform: 'none',
                    display: 'flex',
                    gap: 1.5,
                    '&:hover': {
                      bgcolor: '#F8F9FA',
                      border: '2px solid #0f4e9d',
                      boxShadow: '0 4px 12px rgba(15, 78, 157, 0.15)',
                    },
                    '&:disabled': {
                      bgcolor: '#F5F5F5',
                      border: '2px solid #E0E0E0',
                    },
                  }}
                >
                  <img
                    src="/google.png"
                    alt="Google"
                    style={{ width: '20px', height: '20px' }}
                  />
                  Continue with Google
                </Button>

                {/* Toggle Login/Register */}
                <Box sx={{ width: '100%', textAlign: 'center' }}>
                  <Typography variant="body2" color="text.secondary">
                    {isRegister ? 'Already have an account?' : "Don't have an account?"}{' '}
                    <Link
                      component="button"
                      type="button"
                      onClick={toggleMode}
                      sx={{
                        fontWeight: 600,
                        color: 'primary.main',
                        textDecoration: 'none',
                        '&:hover': {
                          textDecoration: 'underline',
                        },
                      }}
                    >
                      {isRegister ? 'Sign In' : 'Register'}
                    </Link>
                  </Typography>
                </Box>

                {/* Trust Indicators */}
                <Box sx={{ width: '100%', pt: 2 }}>
                  <Stack
                    direction="row"
                    spacing={2}
                    justifyContent="center"
                    sx={{ opacity: 0.7 }}
                  >
                    <Typography variant="caption" color="text.secondary">
                      🔒 Secure
                    </Typography>
                    <Typography variant="caption" color="text.secondary">
                      •
                    </Typography>
                    <Typography variant="caption" color="text.secondary">
                      ⚡ Fast
                    </Typography>
                    <Typography variant="caption" color="text.secondary">
                      •
                    </Typography>
                    <Typography variant="caption" color="text.secondary">
                      ✓ Trusted
                    </Typography>
                  </Stack>
                </Box>

                {/* Footer */}
                <Typography
                  variant="caption"
                  color="text.secondary"
                  textAlign="center"
                  sx={{ pt: 2 }}
                >
                  By continuing, you agree to Adna's Terms of Service and Privacy Policy
                </Typography>
              </Stack>
            </Paper>
          </Container>
        </Grid>
      </Grid>
    </Box>
  );
};

export default LoginPage;
