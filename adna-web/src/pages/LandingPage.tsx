import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import {
  Box,
  Container,
  Typography,
  Button,
  Grid,
  Card,
  CardContent,
  Chip,
  AppBar,
  Toolbar,
  IconButton,
  useScrollTrigger,
  Zoom,
  Drawer,
  List,
  ListItem,
  ListItemButton,
  ListItemText,
  Divider,
  useTheme,
  useMediaQuery,
} from '@mui/material';
import {
  TrendingUp,
  Security,
  Speed,
  Analytics,
  QrCode2,
  AccountBalance,
  ArrowForward,
  Login,
  Twitter,
  LinkedIn,
  Email,
  Menu as MenuIcon,
  Close as CloseIcon,
} from '@mui/icons-material';

const LandingPage: React.FC = () => {
  const navigate = useNavigate();
  const trigger = useScrollTrigger({ disableHysteresis: true, threshold: 0 });
  const theme = useTheme();
  const isMobile = useMediaQuery(theme.breakpoints.down('md'));
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const { user, loading, signOut } = useAuth();

  // If user is authenticated, redirect to dashboard (fast path for returning users)
  React.useEffect(() => {
    if (!loading && user) {
      navigate('/dashboard');
    }
  }, [user, loading, navigate]);

  const handleScroll = (sectionId: string) => {
    setMobileMenuOpen(false);
    setTimeout(() => {
      document.getElementById(sectionId)?.scrollIntoView({ behavior: 'smooth' });
    }, 100);
  };

  const handleSignIn = () => {
    // navigate to login page (existing users)
    setMobileMenuOpen(false);
    navigate('/login');
  };

  const handleRequestAccess = () => {
    // navigate to login page but request registration mode
    setMobileMenuOpen(false);
    navigate('/login', { state: { register: true } });
  };

  const features = [
    {
      icon: <AccountBalance sx={{ fontSize: 48 }} />,
      title: 'Instant Settlement',
      description: 'Automated processing. Funds settle to your business account quickly.',
      color: '#0f4e9d',
    },
    {
      icon: <Speed sx={{ fontSize: 48 }} />,
      title: 'Multiple Options',
      description: 'Support for Bitcoin (BTC), Tether (USDT), and USD Coin (USDC).',
      color: '#1a73e8',
    },
    {
      icon: <Analytics sx={{ fontSize: 48 }} />,
      title: 'Dashboard',
      description: 'Track transactions, generate reports, and manage payments.',
      color: '#0a3d7a',
    },
    {
      icon: <Security sx={{ fontSize: 48 }} />,
      title: 'Secure',
      description: 'Built with compliance and security as core principles.',
      color: '#0f4e9d',
    },
    {
      icon: <TrendingUp sx={{ fontSize: 48 }} />,
      title: 'Transparent Pricing',
      description: 'Simple fee structure. No hidden costs.',
      color: '#0a3d7a',
    },
  ];

  return (
    <Box sx={{ bgcolor: 'background.default', minHeight: '100vh' }}>
      {/* Navigation Bar */}
      <AppBar
        position="sticky"
        elevation={trigger ? 4 : 0}
        sx={{
          bgcolor: 'white',
          transition: 'all 0.3s',
        }}
      >
        <Toolbar>
          <Box sx={{ display: 'flex', alignItems: 'center', flexGrow: 1 }}>
            <img
              src="/logo.png"
              alt="Adna"
              style={{ height: 40, marginRight: 12 }}
            />
            <Typography
              variant="h5"
              sx={{
                fontWeight: 700,
                color: '#0f4e9d',
                letterSpacing: 1,
              }}
            >
              Adna
            </Typography>
          </Box>

          {/* Desktop Menu */}
          {!isMobile && (
            <>
              <Box sx={{ display: 'flex', gap: 2, alignItems: 'center', mr: 2 }}>
                <Button
                  sx={{
                    color: 'text.primary',
                    fontWeight: 500,
                    textTransform: 'none',
                    '&:hover': { bgcolor: 'transparent', color: '#0f4e9d' },
                  }}
                  onClick={() => handleScroll('platform')}
                >
                  Platform
                </Button>
                <Button
                  sx={{
                    color: 'text.primary',
                    fontWeight: 500,
                    textTransform: 'none',
                    '&:hover': { bgcolor: 'transparent', color: '#0f4e9d' },
                  }}
                  onClick={() => handleScroll('features')}
                >
                  Features
                </Button>
                <Button
                  sx={{
                    color: 'text.primary',
                    fontWeight: 500,
                    textTransform: 'none',
                    '&:hover': { bgcolor: 'transparent', color: '#0f4e9d' },
                  }}
                  onClick={() => handleScroll('about')}
                >
                  About
                </Button>
                <Button
                  sx={{
                    color: 'text.primary',
                    fontWeight: 500,
                    textTransform: 'none',
                    '&:hover': { bgcolor: 'transparent', color: '#0f4e9d' },
                  }}
                  onClick={() => navigate('/faq')}
                >
                  FAQ
                </Button>
                <Button
                  sx={{
                    color: 'text.primary',
                    fontWeight: 500,
                    textTransform: 'none',
                    '&:hover': { bgcolor: 'transparent', color: '#0f4e9d' },
                  }}
                  onClick={() => navigate('/contact')}
                >
                  Contact
                </Button>
              </Box>

              {/* Auth-aware actions */}
              {user ? (
                <>
                  <Button
                    variant="outlined"
                    onClick={() => navigate('/dashboard')}
                    sx={{
                      borderColor: '#0f4e9d',
                      color: '#0f4e9d',
                      fontWeight: 600,
                      textTransform: 'none',
                      px: 2,
                      mr: 1,
                    }}
                  >
                    Dashboard
                  </Button>
                  <Button
                    variant="contained"
                    onClick={async () => { await signOut(); navigate('/'); }}
                    sx={{
                      bgcolor: '#0f4e9d',
                      color: 'white',
                      fontWeight: 600,
                      textTransform: 'none',
                      fontSize: '1rem',
                      px: 3,
                      '&:hover': { bgcolor: '#0a3d7a' },
                    }}
                  >
                    Sign Out
                  </Button>
                </>
              ) : (
                <>
                  <Button
                    variant="outlined"
                    onClick={handleRequestAccess}
                    sx={{
                      borderColor: '#0f4e9d',
                      color: '#0f4e9d',
                      fontWeight: 600,
                      textTransform: 'none',
                      px: 2,
                      mr: 1,
                    }}
                  >
                    Get Started
                  </Button>
                  <Button
                    variant="contained"
                    startIcon={<Login />}
                    onClick={handleSignIn}
                    sx={{
                      bgcolor: '#0f4e9d',
                      color: 'white',
                      fontWeight: 600,
                      textTransform: 'none',
                      fontSize: '1rem',
                      px: 3,
                      '&:hover': { bgcolor: '#0a3d7a' },
                    }}
                  >
                    Sign In
                  </Button>
                </>
              )}
            </>
          )}

          {/* Mobile Menu Button */}
          {isMobile && (
            <IconButton
              onClick={() => setMobileMenuOpen(true)}
              sx={{
                color: '#0f4e9d',
              }}
            >
              <MenuIcon />
            </IconButton>
          )}
        </Toolbar>
      </AppBar>

      {/* Mobile Drawer Menu */}
      <Drawer
        anchor="right"
        open={mobileMenuOpen}
        onClose={() => setMobileMenuOpen(false)}
        sx={{
          '& .MuiDrawer-paper': {
            width: 280,
            bgcolor: 'white',
          },
        }}
      >
        <Box sx={{ p: 2 }}>
          <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
            <Typography variant="h6" sx={{ fontWeight: 700, color: '#0f4e9d' }}>
              Menu
            </Typography>
            <IconButton onClick={() => setMobileMenuOpen(false)}>
              <CloseIcon />
            </IconButton>
          </Box>
          <Divider sx={{ mb: 2 }} />
          <List>
            <ListItem disablePadding>
              <ListItemButton onClick={() => handleScroll('platform')}>
                <ListItemText
                  primary="Platform"
                  primaryTypographyProps={{
                    fontWeight: 600,
                    color: '#0f4e9d',
                  }}
                />
              </ListItemButton>
            </ListItem>
            <ListItem disablePadding>
              <ListItemButton onClick={() => handleScroll('features')}>
                <ListItemText
                  primary="Features"
                  primaryTypographyProps={{
                    fontWeight: 600,
                    color: '#0f4e9d',
                  }}
                />
              </ListItemButton>
            </ListItem>
            <ListItem disablePadding>
              <ListItemButton onClick={() => handleScroll('about')}>
                <ListItemText
                  primary="About"
                  primaryTypographyProps={{
                    fontWeight: 600,
                    color: '#0f4e9d',
                  }}
                />
              </ListItemButton>
            </ListItem>
            <ListItem disablePadding>
              <ListItemButton onClick={() => { setMobileMenuOpen(false); navigate('/faq'); }}>
                <ListItemText
                  primary="FAQ"
                  primaryTypographyProps={{
                    fontWeight: 600,
                    color: '#0f4e9d',
                  }}
                />
              </ListItemButton>
            </ListItem>
            <ListItem disablePadding>
              <ListItemButton onClick={() => { setMobileMenuOpen(false); navigate('/contact'); }}>
                <ListItemText
                  primary="Contact"
                  primaryTypographyProps={{
                    fontWeight: 600,
                    color: '#0f4e9d',
                  }}
                />
              </ListItemButton>
            </ListItem>
          </List>
          <Divider sx={{ my: 2 }} />
          <Button
            variant="outlined"
            fullWidth
            onClick={handleRequestAccess}
            sx={{
              borderColor: '#0f4e9d',
              color: '#0f4e9d',
              fontWeight: 600,
              textTransform: 'none',
              py: 1.5,
              mb: 1,
              touchAction: 'manipulation',
              cursor: 'pointer',
              '&:hover': {
                borderColor: '#0a3d7a',
                bgcolor: 'rgba(15, 78, 157, 0.05)',
              },
              '&:active': {
                transform: 'scale(0.98)',
              },
            }}
          >
            Get Started
          </Button>
          <Button
            variant="contained"
            fullWidth
            onClick={handleSignIn}
            startIcon={<Login />}
            sx={{
              bgcolor: '#0f4e9d',
              color: 'white',
              fontWeight: 600,
              textTransform: 'none',
              py: 1.5,
              touchAction: 'manipulation',
              cursor: 'pointer',
              '&:hover': {
                bgcolor: '#0a3d7a',
              },
              '&:active': {
                transform: 'scale(0.98)',
              },
            }}
          >
            Sign In
          </Button>
        </Box>
      </Drawer>

      {/* Hero Section */}
      <Box
        sx={{
          bgcolor: 'white',
          color: '#0a3d7a',
          pt: 8,
          pb: 12,
          position: 'relative',
          overflow: 'hidden',
        }}
      >
        <Container maxWidth="lg">
          <Grid container spacing={6} alignItems="center">
            <Grid item xs={12} md={6}>
              <Zoom in timeout={1000}>
                <Box>
                  <Typography
                    variant="h2"
                    sx={{
                      fontWeight: 800,
                      mb: 3,
                      fontSize: { xs: '2.25rem', md: '3.5rem' },
                      lineHeight: 1.18,
                      color: '#0a3d7a',
                    }}
                  >
                    Accept Digital Assets.
                    <br />
                    Receive Local Currency. Instantly.
                  </Typography>
                  <Typography
                    variant="h6"
                    sx={{
                      mb: 4,
                      color: 'text.secondary',
                      lineHeight: 1.6,
                      fontSize: '1.15rem',
                    }}
                  >
                    The payment gateway built for modern businesses.
                  </Typography>
                  <Box sx={{ display: 'flex', gap: 2, flexWrap: 'wrap' }}>
                    <Button
                      variant="contained"
                      size="large"
                      endIcon={<ArrowForward />}
                      onClick={handleRequestAccess}
                      sx={{
                        bgcolor: '#0f4e9d',
                        color: 'white',
                        fontWeight: 700,
                        fontSize: '1.05rem',
                        px: 3.5,
                        py: 1.25,
                        textTransform: 'none',
                        boxShadow: '0 12px 32px rgba(15, 78, 157, 0.35)',
                        touchAction: 'manipulation',
                        cursor: 'pointer',
                        '&:hover': {
                          bgcolor: '#0a3d7a',
                          transform: 'translateY(-2px)',
                          boxShadow: '0 16px 40px rgba(15, 78, 157, 0.45)',
                        },
                        '&:active': {
                          transform: 'scale(0.98)',
                        },
                        transition: 'all 0.25s',
                      }}
                    >
                      Get Started
                    </Button>
                    <Button
                      variant="outlined"
                      size="large"
                      onClick={() => {
                        document.getElementById('about')?.scrollIntoView({ behavior: 'smooth' });
                      }}
                      sx={{
                        borderColor: '#0f4e9d',
                        color: '#0f4e9d',
                        fontWeight: 600,
                        fontSize: '1.05rem',
                        px: 3.5,
                        py: 1.25,
                        textTransform: 'none',
                        '&:hover': {
                          borderColor: '#0a3d7a',
                          bgcolor: 'rgba(15, 78, 157, 0.04)',
                        },
                      }}
                    >
                      Learn More
                    </Button>
                  </Box>
                </Box>
              </Zoom>
            </Grid>
            <Grid item xs={12} md={6}>
              <Zoom in timeout={1200}>
                <Box
                  component="img"
                  src="/hero sector.png"
                  alt="Adna Payment Platform"
                  sx={{
                    width: '100%',
                    height: 'auto',
                    borderRadius: 4,
                    boxShadow: '0 20px 60px rgba(0,0,0,0.3)',
                  }}
                />
              </Zoom>
            </Grid>
          </Grid>
        </Container>
      </Box>
      {/* How It Works */}
      <Box id="platform" sx={{ py: 8, px: 3, bgcolor: 'background.paper' }}>
        <Container maxWidth="md">
          <Typography variant="h4" align="center" fontWeight={800} sx={{ color: '#0a3d7a', mb: 2 }}>
            How it works
          </Typography>
          <Typography variant="body1" align="center" color="text.secondary" sx={{ maxWidth: 800, mx: 'auto', mb: 4 }}>
            A simple 3-step flow to accept digital assets and receive local currency instantly.
          </Typography>

          <Grid container spacing={4}>
            <Grid item xs={12} md={4}>
              <Card sx={{ p: 3, textAlign: 'center', borderRadius: 3, boxShadow: '0 8px 30px rgba(10,61,122,0.04)' }}>
                <Speed sx={{ fontSize: 48, color: '#0f4e9d' }} />
                <Typography variant="h6" fontWeight={700} sx={{ mt: 2 }}>Create Payment Request</Typography>
                <Typography variant="body2" color="text.secondary">Enter amount. Generate payment code.</Typography>
              </Card>
            </Grid>
            <Grid item xs={12} md={4}>
              <Card sx={{ p: 3, textAlign: 'center', borderRadius: 3, boxShadow: '0 8px 30px rgba(10,61,122,0.04)' }}>
                <QrCode2 sx={{ fontSize: 48, color: '#0f4e9d' }} />
                <Typography variant="h6" fontWeight={700} sx={{ mt: 2 }}>Customer Pays</Typography>
                <Typography variant="body2" color="text.secondary">Scan and pay with their preferred digital wallet.</Typography>
              </Card>
            </Grid>
            <Grid item xs={12} md={4}>
              <Card sx={{ p: 3, textAlign: 'center', borderRadius: 3, boxShadow: '0 8px 30px rgba(10,61,122,0.04)' }}>
                <AccountBalance sx={{ fontSize: 48, color: '#0f4e9d' }} />
                <Typography variant="h6" fontWeight={700} sx={{ mt: 2 }}>Receive Settlement</Typography>
                <Typography variant="body2" color="text.secondary">Funds arrive in your business account.</Typography>
              </Card>
            </Grid>
          </Grid>
        </Container>
      </Box>

      {/* Who We Serve */}
      <Box sx={{ py: 8, px: 3 }}>
        <Container maxWidth="lg">
          <Grid container spacing={4} alignItems="center">
            <Grid item xs={12} md={6}>
              <Typography variant="h4" fontWeight={800} sx={{ color: '#0a3d7a', mb: 2 }}>Who we serve</Typography>
              <Typography variant="body1" color="text.secondary" sx={{ mb: 3 }}>
                Built for businesses that need fast settlement times, secure transactions, simple payment acceptance and professional tools.
              </Typography>
              <Box sx={{ display: 'flex', gap: 2, flexWrap: 'wrap' }}>
                {['Automotive','Real Estate','Luxury Retail','Wholesale Trade','Supermarkets'].map((i) => (
                  <Chip key={i} label={i} sx={{ bgcolor: '#f5f8ff', color: '#0f4e9d', fontWeight: 600 }} />
                ))}
              </Box>
            </Grid>
            <Grid item xs={12} md={6}>
              <Box sx={{ borderRadius: 3, p: 3, bgcolor: '#f7fbff', boxShadow: '0 12px 40px rgba(15,78,157,0.04)' }}>
                <Typography variant="h6" fontWeight={700} sx={{ mb: 1 }}>We help businesses with:</Typography>
                <ul>
                  <li>Fast settlement times</li>
                  <li>Secure transactions</li>
                  <li>Simple payment acceptance</li>
                  <li>Professional tools and reporting</li>
                </ul>
              </Box>
            </Grid>
          </Grid>
        </Container>
      </Box>

      {/* Features Section */}
      <Container maxWidth="lg" id="features" sx={{ py: 10 }}>
        <Box sx={{ textAlign: 'center', mb: 8 }}>
          <Typography
            variant="h3"
            sx={{
              fontWeight: 800,
              mb: 2,
              color: '#0a3d7a',
            }}
          >
            Why Choose Adna?
          </Typography>
          <Typography variant="h6" color="text.secondary" sx={{ maxWidth: 600, mx: 'auto' }}>
            Everything you need to accept payments and manage your business finances
          </Typography>
        </Box>

        <Grid container spacing={4}>
          {features.map((feature, index) => (
            <Grid item xs={12} sm={6} md={4} key={index}>
              <Zoom in timeout={800 + index * 200}>
                <Card
                  sx={{
                    height: '100%',
                    background: `linear-gradient(135deg, ${feature.color}15 0%, ${feature.color}30 100%)`,
                    border: `1px solid ${feature.color}20`,
                    transition: 'all 0.3s',
                    '&:hover': {
                      transform: 'translateY(-8px)',
                      boxShadow: `0 12px 40px ${feature.color}30`,
                    },
                  }}
                >
                  <CardContent sx={{ p: 4, textAlign: 'center' }}>
                    <Box
                      sx={{
                        width: 80,
                        height: 80,
                        borderRadius: '50%',
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                        background: `linear-gradient(135deg, ${feature.color}25 0%, ${feature.color}45 100%)`,
                        color: feature.color,
                        mx: 'auto',
                        mb: 3,
                        boxShadow: `0 4px 12px ${feature.color}20`,
                      }}
                    >
                      {feature.icon}
                    </Box>
                    <Typography variant="h5" fontWeight={700} gutterBottom>
                      {feature.title}
                    </Typography>
                    <Typography variant="body1" color="text.secondary">
                      {feature.description}
                    </Typography>
                  </CardContent>
                </Card>
              </Zoom>
            </Grid>
          ))}
        </Grid>
      </Container>

      {/* Trusted Infrastructure / Partners Section */}
      <Box sx={{ py: 8, px: 3, bgcolor: 'background.paper' }}>
        <Container maxWidth="lg">
          <Typography variant="h5" align="center" fontWeight={800} sx={{ color: '#0a3d7a', mb: 3 }}>
            Trusted Infrastructure
          </Typography>
          <Typography variant="body1" align="center" color="text.secondary" sx={{ maxWidth: 800, mx: 'auto', mb: 4 }}>
            Built on reliable, licensed platforms
          </Typography>

          <Grid container spacing={4} justifyContent="center" alignItems="center">
            {[
              { src: '/quidax.png', alt: 'Quidax' },
              { src: '/Paystack_Logo.png', alt: 'Paystack' },
              { src: '/vite.png', alt: 'Vite' },
              { src: '/youverify.png', alt: 'Youverify' },
            ].map((partner, i) => (
              <Grid item xs={12} sm={6} md={3} key={i}>
                <Box
                  sx={{
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    p: 3,
                    borderRadius: 2,
                    transition: 'all 0.3s ease',
                    bgcolor: 'transparent',
                    '&:hover': {
                      transform: 'scale(1.1)',
                    },
                  }}
                >
                  <Box
                    component="img"
                    src={partner.src}
                    alt={partner.alt}
                    sx={{
                      height: 60,
                      width: 'auto',
                      maxWidth: 150,
                      objectFit: 'contain',
                    }}
                  />
                </Box>
              </Grid>
            ))}
          </Grid>
        </Container>
      </Box>

  {/* CTA Section */}
      <Box
        id="pricing"
        sx={{
          background: 'linear-gradient(135deg, #0a3d7a 0%, #0f4e9d 50%, #1a73e8 100%)',
          py: 12,
          px: 3,
          position: 'relative',
          overflow: 'hidden',
          '&::before': {
            content: '""',
            position: 'absolute',
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            background: 'radial-gradient(circle at 20% 50%, rgba(255,255,255,0.1) 0%, transparent 50%), radial-gradient(circle at 80% 50%, rgba(255,255,255,0.1) 0%, transparent 50%)',
          },
        }}
      >
        <Container maxWidth="md" sx={{ position: 'relative', zIndex: 1 }}>
          <Card
            sx={{
              background: 'rgba(255, 255, 255, 0.95)',
              backdropFilter: 'blur(10px)',
              borderRadius: 4,
              boxShadow: '0 24px 48px rgba(0, 0, 0, 0.3), 0 0 80px rgba(26, 115, 232, 0.4)',
              border: '1px solid rgba(255, 255, 255, 0.3)',
              overflow: 'hidden',
              position: 'relative',
              '&::before': {
                content: '""',
                position: 'absolute',
                top: 0,
                left: 0,
                right: 0,
                height: '4px',
                background: 'linear-gradient(90deg, #0a3d7a 0%, #0f4e9d 50%, #1a73e8 100%)',
              },
            }}
          >
            <CardContent sx={{ p: 6, textAlign: 'center' }}>
              <Typography 
                variant="h3" 
                fontWeight={800} 
                gutterBottom
                sx={{
                  background: 'linear-gradient(135deg, #0a3d7a 0%, #0f4e9d 50%, #1a73e8 100%)',
                  backgroundClip: 'text',
                  WebkitBackgroundClip: 'text',
                  WebkitTextFillColor: 'transparent',
                  mb: 2,
                }}
              >
                Ready to Get Started?
              </Typography>
              <Typography 
                variant="h6" 
                sx={{ 
                  mb: 4, 
                  color: 'text.secondary',
                  fontWeight: 500,
                }}
              >
                Join thousands of Nigerian businesses already using Adna
              </Typography>
              <Button
                variant="contained"
                size="large"
                endIcon={<ArrowForward />}
                onClick={handleRequestAccess}
                sx={{
                  background: 'linear-gradient(135deg, #0a3d7a 0%, #0f4e9d 50%, #1a73e8 100%)',
                  color: 'white',
                  fontWeight: 700,
                  fontSize: '1.15rem',
                  px: { xs: 4, md: 6 },
                  py: { xs: 1.25, md: 2 },
                  textTransform: 'none',
                  boxShadow: '0 20px 50px rgba(15, 78, 157, 0.28), 0 0 120px rgba(15, 78, 157, 0.12)',
                  borderRadius: 3,
                  touchAction: 'manipulation',
                  cursor: 'pointer',
                  '&:hover': {
                    background: 'linear-gradient(135deg, #0a3d7a 20%, #0f4e9d 60%, #1a73e8 100%)',
                    transform: 'translateY(-3px)',
                    boxShadow: '0 28px 68px rgba(15, 78, 157, 0.36)',
                  },
                  '&:active': {
                    transform: 'scale(0.98)',
                  },
                  transition: 'all 0.25s ease',
                }}
              >
                Request Access
              </Button>
              
              {/* Decorative elements */}
              <Box
                sx={{
                  mt: 4,
                  pt: 3,
                  borderTop: '1px solid rgba(15, 78, 157, 0.1)',
                  display: 'flex',
                  justifyContent: 'center',
                  gap: 4,
                  flexWrap: 'wrap',
                }}
              >
                <Box sx={{ textAlign: 'center' }}>
                  <Typography variant="h4" fontWeight={700} color="#0f4e9d">
                    99.9%
                  </Typography>
                  <Typography variant="body2" color="text.secondary">
                    Uptime
                  </Typography>
                </Box>
                <Box sx={{ textAlign: 'center' }}>
                  <Typography variant="h4" fontWeight={700} color="#0f4e9d">
                    24/7
                  </Typography>
                  <Typography variant="body2" color="text.secondary">
                    Support
                  </Typography>
                </Box>
                <Box sx={{ textAlign: 'center' }}>
                  <Typography variant="h4" fontWeight={700} color="#0f4e9d">
                    Instant
                  </Typography>
                  <Typography variant="body2" color="text.secondary">
                    Setup
                  </Typography>
                </Box>
              </Box>
            </CardContent>
          </Card>
        </Container>
      </Box>

      {/* About Section */}
      <Box
        id="about"
        sx={{
          py: 10,
          px: 3,
          bgcolor: 'background.paper',
        }}
      >
        <Container maxWidth="lg">
          <Grid container spacing={4}>
            <Grid item xs={12} md={8}>
              <Typography variant="h4" fontWeight={800} sx={{ color: '#0a3d7a', mb: 2 }}>
                About Adna
              </Typography>
              <Typography variant="body1" color="text.secondary" sx={{ mb: 2 }}>
                Adna provides payment infrastructure for businesses that need to accept digital asset payments.
                We built this platform to bridge the gap between emerging payment methods and traditional business operations.
                Our focus is simple: make complex transactions simple, secure, and compliant.
              </Typography>
              <Typography variant="body1" color="text.secondary">
                We work with licensed partners to handle technical operations while providing businesses with straightforward tools to accept payments and receive settlements.
                Founded in 2025, Adna is based in Lagos, Nigeria.
              </Typography>
            </Grid>
            <Grid item xs={12} md={4}>
              <Card sx={{ p: 3, borderRadius: 3, boxShadow: '0 8px 30px rgba(10,61,122,0.04)' }}>
                <Typography variant="h6" fontWeight={700} sx={{ mb: 1 }}>Who we partner with</Typography>
                <Typography variant="body2" color="text.secondary">Licensed providers and exchanges who help us deliver compliant settlements.</Typography>
              </Card>
            </Grid>
          </Grid>
        </Container>
      </Box>

      {/* Footer */}
      <Box
        id="footer"
        sx={{
          bgcolor: '#0a3d7a',
          color: 'white',
          py: 6,
        }}
      >
        <Container maxWidth="lg">
          <Grid container spacing={4}>
            <Grid item xs={12} md={4}>
              <Box sx={{ display: 'flex', alignItems: 'center', mb: 2 }}>
                <img
                  src="/logo-white.png"
                  alt="Adna"
                  style={{ height: 40, marginRight: 12 }}
                />
                <Typography variant="h5" fontWeight={700}>
                  Adna
                </Typography>
              </Box>
              <Typography variant="body2" sx={{ opacity: 0.8 }}>
                Modern payment solutions for Nigerian businesses.
                Accept payments, manage finances, and grow your business.
              </Typography>
            </Grid>
            <Grid item xs={12} md={3}>
              <Typography variant="h6" fontWeight={700} gutterBottom>
                Platform
              </Typography>
              <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1 }}>
                <Button onClick={() => handleScroll('platform')} sx={{ color: 'white', justifyContent: 'flex-start', textTransform: 'none' }}>Platform</Button>
                <Button onClick={() => handleScroll('features')} sx={{ color: 'white', justifyContent: 'flex-start', textTransform: 'none' }}>Features</Button>
                <Button onClick={() => handleScroll('pricing')} sx={{ color: 'white', justifyContent: 'flex-start', textTransform: 'none' }}>Pricing</Button>
                <Button onClick={() => window.open('/docs', '_blank')} sx={{ color: 'white', justifyContent: 'flex-start', textTransform: 'none' }}>Documentation</Button>
              </Box>
            </Grid>
            <Grid item xs={12} md={2}>
              <Typography variant="h6" fontWeight={700} gutterBottom>
                Platform
              </Typography>
              <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1 }}>
                <Button onClick={() => handleScroll('platform')} sx={{ color: 'white', justifyContent: 'flex-start', textTransform: 'none' }}>Platform</Button>
                <Button onClick={() => handleScroll('features')} sx={{ color: 'white', justifyContent: 'flex-start', textTransform: 'none' }}>Features</Button>
                <Button onClick={() => handleScroll('pricing')} sx={{ color: 'white', justifyContent: 'flex-start', textTransform: 'none' }}>How it works</Button>
              </Box>
            </Grid>
            <Grid item xs={12} md={2}>
              <Typography variant="h6" fontWeight={700} gutterBottom>
                Company
              </Typography>
              <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1 }}>
                <Button onClick={() => handleScroll('about')} sx={{ color: 'white', justifyContent: 'flex-start', textTransform: 'none' }}>About</Button>
                <Button onClick={() => navigate('/contact')} sx={{ color: 'white', justifyContent: 'flex-start', textTransform: 'none' }}>Contact</Button>
                <Button onClick={() => window.open('/careers', '_blank')} sx={{ color: 'white', justifyContent: 'flex-start', textTransform: 'none' }}>Careers</Button>
              </Box>
            </Grid>
            <Grid item xs={12} md={3}>
              <Typography variant="h6" fontWeight={700} gutterBottom>
                Resources
              </Typography>
              <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1 }}>
                <Button onClick={() => navigate('/faq')} sx={{ color: 'white', justifyContent: 'flex-start', textTransform: 'none' }}>FAQ</Button>
                <Button onClick={() => window.open('/docs', '_blank')} sx={{ color: 'white', justifyContent: 'flex-start', textTransform: 'none' }}>Documentation</Button>
                <Button onClick={() => navigate('/contact')} sx={{ color: 'white', justifyContent: 'flex-start', textTransform: 'none' }}>Support</Button>
              </Box>
            </Grid>
            <Grid item xs={12} md={3}>
              <Typography variant="h6" fontWeight={700} gutterBottom>
                Legal
              </Typography>
              <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1 }}>
                <Button onClick={() => window.open('/terms', '_blank')} sx={{ color: 'white', justifyContent: 'flex-start', textTransform: 'none' }}>Terms of Service</Button>
                <Button onClick={() => window.open('/privacy', '_blank')} sx={{ color: 'white', justifyContent: 'flex-start', textTransform: 'none' }}>Privacy Policy</Button>
                <Button onClick={() => window.open('/compliance', '_blank')} sx={{ color: 'white', justifyContent: 'flex-start', textTransform: 'none' }}>Compliance</Button>
              </Box>
            </Grid>
            <Grid item xs={12} md={2}>
              <Typography variant="h6" fontWeight={700} gutterBottom>
                Connect
              </Typography>
              <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1 }}>
                <Button startIcon={<LinkedIn />} onClick={() => window.open('https://linkedin.com/company/adnalabs', '_blank')} sx={{ color: 'white', justifyContent: 'flex-start', textTransform: 'none' }}>LinkedIn</Button>
                <Button startIcon={<Twitter />} onClick={() => window.open('https://twitter.com/adnalabs', '_blank')} sx={{ color: 'white', justifyContent: 'flex-start', textTransform: 'none' }}>Twitter</Button>
                <Button startIcon={<Email />} onClick={() => window.location.href = 'mailto:hello@adna.ng'} sx={{ color: 'white', justifyContent: 'flex-start', textTransform: 'none' }}>hello@adna.ng</Button>
              </Box>
            </Grid>
          </Grid>
          <Box sx={{ borderTop: '1px solid rgba(255,255,255,0.1)', mt: 4, pt: 4, textAlign: 'center' }}>
            <Typography variant="body2" sx={{ opacity: 0.9 }}>
              © 2025 Adna Labs. All rights reserved.
            </Typography>
          </Box>
        </Container>
      </Box>
    </Box>
  );
};

export default LandingPage;
