import React, { useState } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import {
  Box,
  Drawer,
  AppBar,
  Toolbar,
  List,
  Typography,
  Divider,
  IconButton,
  ListItem,
  ListItemButton,
  ListItemIcon,
  ListItemText,
  Avatar,
  Menu,
  MenuItem,
  Badge,
  useTheme,
  useMediaQuery,
  MenuList,
  ListItemSecondaryAction,
  Tooltip,
  Button,
} from '@mui/material';
import {
  Menu as MenuIcon,
  Dashboard,
  Receipt,
  Payment,
  AttachMoney,
  Settings,
  Logout,
  AdminPanelSettings,
  People,
  Assessment,
  Notifications,
} from '@mui/icons-material';
import { useAuth } from '../contexts/AuthContext';
import { subscribeMerchantNotifications, markNotificationRead, deleteNotification } from '../services/firebase';

const drawerWidth = 260;

interface LayoutProps {
  children: React.ReactNode;
}

const DashboardLayout: React.FC<LayoutProps> = ({ children }) => {
  const { user, merchant, isAdmin, signOut } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();
  const theme = useTheme();
  const isMobile = useMediaQuery(theme.breakpoints.down('md'));

  const [mobileOpen, setMobileOpen] = useState(false);
  const [anchorEl, setAnchorEl] = useState<null | HTMLElement>(null);
  const [notifAnchor, setNotifAnchor] = useState<null | HTMLElement>(null);
  const [notifications, setNotifications] = useState<any[]>([]);

  const handleDrawerToggle = () => {
    setMobileOpen(!mobileOpen);
  };

  const handleProfileMenuOpen = (event: React.MouseEvent<HTMLElement>) => {
    setAnchorEl(event.currentTarget);
  };

  const handleNotifOpen = (e: React.MouseEvent<HTMLElement>) => {
    setNotifAnchor(e.currentTarget);
  };

  const handleNotifClose = () => setNotifAnchor(null);

  const handleProfileMenuClose = () => {
    setAnchorEl(null);
  };

  // Subscribe to merchant notifications when merchant is available
  React.useEffect(() => {
    if (!merchant) return;
    const unsub = subscribeMerchantNotifications(merchant.id, (items) => {
      setNotifications(items || []);
    });
    return () => unsub();
  }, [merchant]);

  const handleSignOut = async () => {
    handleProfileMenuClose();
    await signOut();
    navigate('/');
  };

  // Merchant menu items
  const merchantMenuItems = [
    { text: 'Dashboard', icon: <Dashboard />, path: '/dashboard' },
    { text: 'Transactions', icon: <Receipt />, path: '/transactions' },
    { text: 'Payments', icon: <Payment />, path: '/payments' },
    { text: 'Billing', icon: <AttachMoney />, path: '/billing' },
    { text: 'Settings', icon: <Settings />, path: '/settings' },
  ];

  // Admin menu items
  const adminMenuItems = [
    { text: 'Admin Dashboard', icon: <AdminPanelSettings />, path: '/admin' },
    { text: 'Merchants', icon: <People />, path: '/admin/merchants' },
    { text: 'Transactions', icon: <Assessment />, path: '/admin/transactions' },
  ];

  const drawer = (
    <Box>
      <Toolbar sx={{ display: 'flex', flexDirection: 'column', alignItems: 'center', py: 3, gap: 0.5 }}>
        <Box
          sx={{
            width: 60,
            height: 60,
            borderRadius: '50%',
            bgcolor: 'white',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            boxShadow: '0 4px 12px rgba(15, 78, 157, 0.15)',
            mb: 1,
          }}
        >
          <img
            src="/logo.png"
            alt="Adna Logo"
            style={{
              width: '40px',
              height: '40px',
              objectFit: 'contain',
            }}
          />
        </Box>
        <Typography
          variant="h6"
          sx={{
            fontWeight: 700,
            color: '#0f4e9d',
            letterSpacing: 0.5,
          }}
        >
          Adna
        </Typography>
      </Toolbar>
      <Divider sx={{ mx: 2, my: 1 }} />
      <List sx={{ px: 2, py: 1 }}>
        {merchantMenuItems.map((item) => (
          <ListItem key={item.text} disablePadding sx={{ mb: 0.5 }}>
            <ListItemButton
              selected={location.pathname === item.path}
              onClick={() => {
                navigate(item.path);
                if (isMobile) setMobileOpen(false);
              }}
              sx={{
                borderRadius: 2,
                py: 1.25,
                px: 2,
                transition: 'all 0.2s',
                '&.Mui-selected': {
                  bgcolor: 'primary.main',
                  color: 'white',
                  boxShadow: '0 4px 12px rgba(15, 78, 157, 0.25)',
                  '&:hover': {
                    bgcolor: 'primary.dark',
                  },
                  '& .MuiListItemIcon-root': {
                    color: 'white',
                  },
                },
                '&:hover': {
                  bgcolor: 'rgba(15, 78, 157, 0.08)',
                },
              }}
            >
              <ListItemIcon sx={{ minWidth: 40, color: 'primary.main' }}>
                {item.icon}
              </ListItemIcon>
              <ListItemText 
                primary={item.text}
                primaryTypographyProps={{
                  fontSize: '0.9rem',
                  fontWeight: 500,
                }}
              />
            </ListItemButton>
          </ListItem>
        ))}
      </List>

      {isAdmin && (
        <>
          <Divider sx={{ mx: 2, my: 2 }} />
          <List sx={{ px: 2, py: 1 }}>
            <Typography 
              variant="caption" 
              sx={{ 
                px: 2, 
                color: 'text.secondary', 
                fontWeight: 600,
                letterSpacing: 1,
                fontSize: '0.7rem',
              }}
            >
              ADMIN PANEL
            </Typography>
            {adminMenuItems.map((item) => (
              <ListItem key={item.text} disablePadding sx={{ mb: 0.5, mt: 1 }}>
                <ListItemButton
                  selected={location.pathname === item.path}
                  onClick={() => {
                    navigate(item.path);
                    if (isMobile) setMobileOpen(false);
                  }}
                  sx={{
                    borderRadius: 2,
                    py: 1.25,
                    px: 2,
                    transition: 'all 0.2s',
                    '&.Mui-selected': {
                      bgcolor: 'secondary.main',
                      color: 'white',
                      boxShadow: '0 4px 12px rgba(26, 115, 232, 0.25)',
                      '&:hover': {
                        bgcolor: 'secondary.dark',
                      },
                      '& .MuiListItemIcon-root': {
                        color: 'white',
                      },
                    },
                    '&:hover': {
                      bgcolor: 'rgba(26, 115, 232, 0.08)',
                    },
                  }}
                >
                  <ListItemIcon sx={{ minWidth: 40, color: 'secondary.main' }}>
                    {item.icon}
                  </ListItemIcon>
                  <ListItemText 
                    primary={item.text}
                    primaryTypographyProps={{
                      fontSize: '0.9rem',
                      fontWeight: 500,
                    }}
                  />
                </ListItemButton>
              </ListItem>
            ))}
          </List>
        </>
      )}
    </Box>
  );

  return (
    <Box sx={{ display: 'flex' }}>
      <AppBar
        position="fixed"
        sx={{
          width: { md: `calc(100% - ${drawerWidth}px)` },
          ml: { md: `${drawerWidth}px` },
          bgcolor: 'background.paper',
          color: 'text.primary',
          boxShadow: '0 1px 3px rgba(0,0,0,0.08)',
        }}
      >
        <Toolbar>
          <IconButton
            color="inherit"
            edge="start"
            onClick={handleDrawerToggle}
            sx={{ mr: 2, display: { md: 'none' } }}
          >
            <MenuIcon />
          </IconButton>
          <Typography variant="h6" noWrap component="div" sx={{ flexGrow: 1 }}>
            {merchant?.businessName || user?.displayName || 'Welcome'}
          </Typography>

          <IconButton color="inherit" sx={{ mr: 1 }}>
            <Badge badgeContent={notifications.filter(n => !n.read).length} color="error">
              <Tooltip title="Notifications">
                <IconButton color="inherit" onClick={handleNotifOpen} size="large">
                  <Notifications />
                </IconButton>
              </Tooltip>
            </Badge>
          </IconButton>

          <Menu
            anchorEl={notifAnchor}
            open={Boolean(notifAnchor)}
            onClose={handleNotifClose}
            anchorOrigin={{ vertical: 'bottom', horizontal: 'right' }}
            transformOrigin={{ vertical: 'top', horizontal: 'right' }}
            PaperProps={{ sx: { width: 360, maxWidth: '90vw' } }}
          >
            <Box sx={{ px: 2, py: 1 }}>
              <Typography variant="subtitle1">Notifications</Typography>
            </Box>
            <Divider />
            {notifications.length === 0 ? (
              <Box sx={{ p: 2 }}>
                <Typography variant="body2" color="text.secondary">No notifications</Typography>
              </Box>
            ) : (
              <MenuList>
                {notifications.map((n) => (
                  <MenuItem key={n.id} sx={{ alignItems: 'flex-start' }}>
                    <Box sx={{ flex: 1 }}>
                      <Typography variant="body2" sx={{ fontWeight: n.read ? 400 : 700 }}>{n.title || 'Notification'}</Typography>
                      <Typography variant="caption" color="text.secondary">{n.body || n.message || ''}</Typography>
                    </Box>
                    <ListItemSecondaryAction>
                      {!n.read && (
                        <Button size="small" onClick={async () => { try { await markNotificationRead(merchant!.id, n.id); } catch (err) { console.error(err); } }}>Mark read</Button>
                      )}
                      <Button size="small" color="error" onClick={async () => { try { await deleteNotification(merchant!.id, n.id); } catch (err) { console.error(err); } }}>Delete</Button>
                    </ListItemSecondaryAction>
                  </MenuItem>
                ))}
              </MenuList>
            )}
          </Menu>

          <IconButton onClick={handleProfileMenuOpen} sx={{ ml: 1 }}>
            <Avatar
              src={user?.photoURL || undefined}
              alt={user?.displayName || 'User'}
              sx={{ width: 36, height: 36 }}
            >
              {user?.displayName?.charAt(0) || user?.email?.charAt(0)}
            </Avatar>
          </IconButton>

          <Menu
            anchorEl={anchorEl}
            open={Boolean(anchorEl)}
            onClose={handleProfileMenuClose}
            anchorOrigin={{
              vertical: 'bottom',
              horizontal: 'right',
            }}
            transformOrigin={{
              vertical: 'top',
              horizontal: 'right',
            }}
          >
            <Box sx={{ px: 2, py: 1.5, minWidth: 200 }}>
              <Typography variant="subtitle2" fontWeight={600}>
                {user?.displayName}
              </Typography>
              <Typography variant="caption" color="text.secondary">
                {user?.email}
              </Typography>
              {isAdmin && (
                <Typography variant="caption" display="block" color="error.main" sx={{ mt: 0.5, fontWeight: 600 }}>
                  🔐 Admin Access
                </Typography>
              )}
            </Box>
            <Divider />
            <MenuItem onClick={() => { handleProfileMenuClose(); navigate('/settings'); }}>
              <ListItemIcon>
                <Settings fontSize="small" />
              </ListItemIcon>
              <ListItemText>Settings</ListItemText>
            </MenuItem>
            <MenuItem onClick={handleSignOut}>
              <ListItemIcon>
                <Logout fontSize="small" />
              </ListItemIcon>
              <ListItemText>Sign Out</ListItemText>
            </MenuItem>
          </Menu>
        </Toolbar>
      </AppBar>

      <Box
        component="nav"
        sx={{ width: { md: drawerWidth }, flexShrink: { md: 0 } }}
      >
        <Drawer
          variant="temporary"
          open={mobileOpen}
          onClose={handleDrawerToggle}
          ModalProps={{ keepMounted: true }}
          sx={{
            display: { xs: 'block', md: 'none' },
            '& .MuiDrawer-paper': { boxSizing: 'border-box', width: drawerWidth },
          }}
        >
          {drawer}
        </Drawer>
        <Drawer
          variant="permanent"
          sx={{
            display: { xs: 'none', md: 'block' },
            '& .MuiDrawer-paper': { boxSizing: 'border-box', width: drawerWidth },
          }}
          open
        >
          {drawer}
        </Drawer>
      </Box>

      <Box
        component="main"
        sx={{
          flexGrow: 1,
          p: 3,
          width: { md: `calc(100% - ${drawerWidth}px)` },
          minHeight: '100vh',
          bgcolor: 'background.default',
        }}
      >
        <Toolbar />
        {children}
      </Box>
    </Box>
  );
};

export default DashboardLayout;
