import React, { useState } from 'react';
import {
  Box,
  Container,
  Typography,
  Paper,
  Tabs,
  Tab,
  TextField,
  Button,
  Grid,
  Avatar,
  Divider,
  Alert,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  useTheme,
  useMediaQuery,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Autocomplete,
} from '@mui/material';
import { Person, Business, AccountBalance, Security, Key } from '@mui/icons-material';
import DashboardLayout from '../components/DashboardLayout';
import { useAuth } from '../contexts/AuthContext';
import { updateMerchant, reauthenticateWithPassword, changeUserEmail, requestEmailChange, resolveAccountName } from '../services/firebase';
import toast from 'react-hot-toast';
import { useNavigate } from 'react-router-dom';
import banks from '../utils/banks';

interface TabPanelProps {
  children?: React.ReactNode;
  index: number;
  value: number;
}

function TabPanel(props: TabPanelProps) {
  const { children, value, index, ...other } = props;
  return (
    <div role="tabpanel" hidden={value !== index} {...other}>
      {value === index && <Box sx={{ py: 3 }}>{children}</Box>}
    </div>
  );
}

const SettingsPage: React.FC = () => {
  const { merchant, user, refreshMerchant } = useAuth();
  const navigate = useNavigate();
  const [tabValue, setTabValue] = useState(0);
  const [saving, setSaving] = useState(false);
  const theme = useTheme();
  const isMobile = useMediaQuery(theme.breakpoints.down('sm'));

  // Email change dialog state
  const [emailDialogOpen, setEmailDialogOpen] = useState(false);
  const [newEmail, setNewEmail] = useState('');
  const [currentPassword, setCurrentPassword] = useState('');
  const [requestReason, setRequestReason] = useState('');

  // Profile form state
  const [profileData, setProfileData] = useState({
    businessName: merchant?.businessName || '',
    category: merchant?.category || '',
    businessPhone: merchant?.businessPhone || '',
    businessEmail: merchant?.businessEmail || '',
    businessAddress: merchant?.businessAddress || '',
    description: (merchant as any)?.description || '',
  });

  // Owner editable fields (Name & Phone)
  const [ownerData, setOwnerData] = useState({
    ownerName: merchant?.ownerName || user?.displayName || '',
    ownerPhone: merchant?.ownerPhone || merchant?.phoneNumber || '',
    tier: merchant?.tier || 'Tier 1',
  });

  // Bank details state
  const [bankData, setBankData] = useState({
    bankName: merchant?.bankName || '',
    accountNumber: merchant?.accountNumber || '',
    accountName: merchant?.accountName || '',
    accountType: merchant?.accountType || '',
  });
  // Edit mode for bank details: when false show read-only saved bank info, when true show inputs to replace
  const [editBank, setEditBank] = useState(false);

  const handleTabChange = (_event: React.SyntheticEvent, newValue: number) => {
    setTabValue(newValue);
  };

  const handleProfileUpdate = async () => {
    if (!merchant) return;

    try {
      setSaving(true);
      // Update business profile fields
      await updateMerchant(merchant.userId, profileData);
      // Update owner editable fields (name/phone/tier)
      await updateMerchant(merchant.userId, {
        ownerName: ownerData.ownerName,
        ownerPhone: ownerData.ownerPhone,
        tier: ownerData.tier,
      });
      await refreshMerchant();
      toast.success('Profile updated successfully');
    } catch (error) {
      console.error('Error updating profile:', error);
      toast.error('Failed to update profile');
    } finally {
      setSaving(false);
    }
  };

  const handleOwnerChange = async () => {
    if (!merchant) return;
    try {
      setSaving(true);
      await updateMerchant(merchant.userId, {
        ownerName: ownerData.ownerName,
        ownerPhone: ownerData.ownerPhone,
        tier: ownerData.tier,
      });
      await refreshMerchant();
      toast.success('Owner profile updated');
    } catch (err) {
      console.error('Error updating owner:', err);
      toast.error('Failed to update owner info');
    } finally {
      setSaving(false);
    }
  };

  // populate form states when merchant updates
  React.useEffect(() => {
    if (!merchant) return;
    setProfileData({
      businessName: merchant.businessName || '',
      category: merchant.category || '',
      businessPhone: merchant.businessPhone || '',
      businessEmail: merchant.businessEmail || '',
      businessAddress: merchant.businessAddress || '',
      description: (merchant as any).description || '',
    });

    // Populate bankData from multiple possible shapes used by mobile/web
    const bankFromTop = {
      bankName: merchant.bankName || '',
      accountNumber: merchant.accountNumber || '',
      accountName: merchant.accountName || '',
      accountType: merchant.accountType || '',
    };

    const bankFromNested = (merchant as any).bank || (merchant as any).bankDetails || (merchant as any).bank_details || null;

    const resolvedBank = {
      bankName: bankFromNested?.bankName || bankFromNested?.name || bankFromNested?.bank || bankFromTop.bankName,
      accountNumber: bankFromNested?.accountNumber || bankFromNested?.account_number || bankFromTop.accountNumber,
      accountName: bankFromNested?.accountName || bankFromNested?.account_name || bankFromTop.accountName,
      accountType: bankFromNested?.accountType || bankFromNested?.account_type || bankFromTop.accountType,
    };

    setBankData(resolvedBank);

    // If there is existing bank info, keep editBank false (show read-only). If none, open edit mode.
    if (resolvedBank.bankName && resolvedBank.accountNumber) {
      setEditBank(false);
    } else {
      setEditBank(true);
    }

    setOwnerData({
      ownerName: merchant.ownerName || user?.displayName || '',
      ownerPhone: merchant.ownerPhone || merchant.phoneNumber || '',
      tier: merchant.tier || 'Tier 1',
    });
  }, [merchant]);

  const isPasswordProvider = !!(user as any)?.providerData?.find((p: any) => p.providerId === 'password');

  const openEmailDialog = () => {
    setNewEmail(user?.email || '');
    setCurrentPassword('');
    setRequestReason('');
    setEmailDialogOpen(true);
  };

  const closeEmailDialog = () => setEmailDialogOpen(false);

  const handleEmailChangeSubmit = async () => {
    if (!user || !merchant) return;
    try {
      setSaving(true);
      if (isPasswordProvider) {
        // Reauthenticate then change
        await reauthenticateWithPassword(currentPassword);
        await changeUserEmail(newEmail);
        await refreshMerchant();
        toast.success('Email changed. Please verify your new email address.');
      } else {
        // OAuth user; create a request for support to handle
        await requestEmailChange(merchant.userId || merchant.id || user.uid, user.email || '', newEmail, requestReason);
        toast.success('Email change request submitted. Support will review it.');
      }
      setEmailDialogOpen(false);
    } catch (err: any) {
      console.error('Email change error:', err);
      toast.error(err.message || 'Failed to change email');
    } finally {
      setSaving(false);
    }
  };

  const tierOrder: Record<string, number> = {
    'Tier 1': 1,
    'Tier 2': 2,
    'Tier 3': 3,
  };

  const handleTierSelect = (newTier: string) => {
    const current = merchant?.tier || 'Tier 1';
    setOwnerData({ ...ownerData, tier: newTier });

    // If upgrading to a higher tier that may require additional verification, redirect to onboarding
    if (tierOrder[newTier] > tierOrder[current]) {
      toast('Redirecting to onboarding to complete KYC for selected tier...', { icon: '🔒' });
      // persist desired tier so onboarding can pick it up
      updateMerchant(merchant!.userId, { tier: newTier }).catch((e) => console.error(e));
      navigate('/onboarding', { state: { tier: newTier } });
    }
  };

  const handleBankUpdate = async () => {
    if (!merchant) return;

    try {
      setSaving(true);
      // Update both top-level bank fields and nested bank object to remain compatible with mobile app shapes
      // Cast to any to allow writing a nested `bank` object even if Merchant type doesn't declare it
      await updateMerchant(merchant.userId, ({
        ...bankData,
        bank: {
          bankName: bankData.bankName,
          accountNumber: bankData.accountNumber,
          accountName: bankData.accountName,
          accountType: bankData.accountType,
        },
      } as any));
      await refreshMerchant();
      toast.success('Bank details updated successfully');
    } catch (error) {
      console.error('Error updating bank details:', error);
      toast.error('Failed to update bank details');
    } finally {
      setSaving(false);
    }
  };

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

        <Paper>
          {/* Responsive tab selector: dropdown on mobile, tabs on desktop */}
          {isMobile ? (
            <Box sx={{ px: 2, py: 1 }}>
              <FormControl fullWidth>
                <InputLabel id="settings-tab-select-label">Section</InputLabel>
                <Select
                  labelId="settings-tab-select-label"
                  value={tabValue}
                  label="Section"
                  onChange={(e) => setTabValue(Number(e.target.value))}
                >
                  <MenuItem value={0}>Profile</MenuItem>
                  <MenuItem value={1}>Business Info</MenuItem>
                  <MenuItem value={2}>Bank Details</MenuItem>
                  <MenuItem value={3}>API Keys</MenuItem>
                  <MenuItem value={4}>Security</MenuItem>
                </Select>
              </FormControl>
            </Box>
          ) : (
            <Tabs
              value={tabValue}
              onChange={handleTabChange}
              sx={{ borderBottom: 1, borderColor: 'divider', px: 2 }}
            >
              <Tab icon={<Person />} label="Profile" iconPosition="start" />
              <Tab icon={<Business />} label="Business Info" iconPosition="start" />
              <Tab icon={<AccountBalance />} label="Bank Details" iconPosition="start" />
              <Tab icon={<Key />} label="API Keys" iconPosition="start" />
              <Tab icon={<Security />} label="Security" iconPosition="start" />
            </Tabs>
          )}

          {/* Profile Tab */}
          <TabPanel value={tabValue} index={0}>
            <Box sx={{ px: { xs: 2, sm: 3 }, py: { xs: 2, sm: 3 } }}>
              <Box sx={{ display: 'flex', alignItems: 'center', mb: 3, gap: 2, flexWrap: 'wrap' }}>
                <Avatar sx={{ width: { xs: 56, sm: 80 }, height: { xs: 56, sm: 80 } }}>
                  {user?.displayName?.charAt(0) || merchant?.ownerName?.charAt(0) || 'M'}
                </Avatar>
                <Box sx={{ minWidth: 0 }}>
                  <Typography variant="h6" sx={{ fontSize: { xs: '1rem', sm: '1.25rem' } }} noWrap>
                    {merchant?.ownerName || user?.displayName}
                  </Typography>
                  <Typography variant="body2" color="text.secondary" sx={{ fontSize: { xs: '0.75rem', sm: '0.9rem' } }} noWrap>
                    {user?.email}
                  </Typography>
                  <Typography variant="caption" color="text.secondary">
                    KYC Status: <strong>{merchant?.kycStatus?.toUpperCase()}</strong>
                  </Typography>
                </Box>
              </Box>

              <Divider sx={{ my: 2 }} />

              <Grid container spacing={2}>
                <Grid item xs={12}>
                  <TextField
                    fullWidth
                    label="Name"
                    value={ownerData.ownerName}
                    onChange={(e) => setOwnerData({ ...ownerData, ownerName: e.target.value })}
                    helperText="This name does not affect KYC"
                  />
                </Grid>

                <Grid item xs={12} sm={6}>
                  <Box sx={{ display: 'flex', gap: 1, alignItems: 'center' }}>
                    <TextField
                      fullWidth
                      label="Email"
                      value={user?.email || ''}
                      disabled
                      helperText="Contact support to change or click Edit"
                    />
                    <Button variant="outlined" onClick={openEmailDialog} sx={{ whiteSpace: 'nowrap' }}>
                      Edit
                    </Button>
                  </Box>
                </Grid>

                <Grid item xs={12} sm={6}>
                  <TextField
                    fullWidth
                    label="Phone Number"
                    value={ownerData.ownerPhone}
                    onChange={(e) => setOwnerData({ ...ownerData, ownerPhone: e.target.value })}
                    helperText="This phone is not part of KYC verification"
                  />
                </Grid>

                <Grid item xs={12} sm={6}>
                  <FormControl fullWidth>
                    <InputLabel id="tier-select-label">Registration Tier</InputLabel>
                    <Select
                      labelId="tier-select-label"
                      value={ownerData.tier}
                      label="Registration Tier"
                      onChange={(e) => handleTierSelect(e.target.value as string)}
                    >
                      <MenuItem value="Tier 1">Tier 1</MenuItem>
                      <MenuItem value="Tier 2">Tier 2</MenuItem>
                      <MenuItem value="Tier 3">Tier 3</MenuItem>
                    </Select>
                  </FormControl>
                </Grid>

                <Grid item xs={12}>
                  <Box sx={{ display: 'flex', gap: 2, flexWrap: 'wrap' }}>
                    <Button variant="outlined" onClick={() => { setOwnerData({ ownerName: merchant?.ownerName || '', ownerPhone: merchant?.ownerPhone || '', tier: merchant?.tier || 'Tier 1' }); }}>
                      Reset
                    </Button>
                    <Button variant="contained" onClick={handleOwnerChange} disabled={saving}>
                      {saving ? 'Saving...' : 'Save Owner Info'}
                    </Button>
                  </Box>
                </Grid>
              </Grid>
            </Box>
          </TabPanel>

          {/* Business Info Tab */}
          <TabPanel value={tabValue} index={1}>
            <Box sx={{ px: 3 }}>
              <Alert severity="info" sx={{ mb: 3 }}>
                Update your business information. Changes will be reflected immediately.
              </Alert>

              <Grid container spacing={3}>
                <Grid item xs={12}>
                  <TextField
                    fullWidth
                    label="Business Name"
                    value={profileData.businessName}
                    onChange={(e) =>
                      setProfileData({ ...profileData, businessName: e.target.value })
                    }
                  />
                </Grid>
                <Grid item xs={12} sm={6}>
                  <TextField
                    fullWidth
                    label="Business Category"
                    value={profileData.category}
                    onChange={(e) =>
                      setProfileData({ ...profileData, category: e.target.value })
                    }
                  />
                </Grid>
                <Grid item xs={12} sm={6}>
                  <TextField
                    fullWidth
                    label="Business Phone"
                    value={profileData.businessPhone}
                    onChange={(e) =>
                      setProfileData({ ...profileData, businessPhone: e.target.value })
                    }
                  />
                </Grid>
                <Grid item xs={12}>
                  <TextField
                    fullWidth
                    label="Business Address"
                    value={profileData.businessAddress}
                    onChange={(e) => setProfileData({ ...profileData, businessAddress: e.target.value })}
                    multiline
                    rows={2}
                  />
                </Grid>
                <Grid item xs={12}>
                  <TextField
                    fullWidth
                    label="Business Description"
                    value={profileData.description}
                    onChange={(e) => setProfileData({ ...profileData, description: e.target.value })}
                    multiline
                    rows={3}
                  />
                </Grid>
                <Grid item xs={12}>
                  <TextField
                    fullWidth
                    label="Business Email"
                    type="email"
                    value={profileData.businessEmail}
                    onChange={(e) =>
                      setProfileData({ ...profileData, businessEmail: e.target.value })
                    }
                  />
                </Grid>
                <Grid item xs={12} sm={6}>
                  <TextField
                    fullWidth
                    label="CAC Number"
                    value={merchant?.cacNumber || 'N/A'}
                    disabled
                    helperText="Contact support to change"
                  />
                </Grid>
                <Grid item xs={12} sm={6}>
                  <TextField
                    fullWidth
                    label="TIN"
                    value={merchant?.tin || 'N/A'}
                    disabled
                    helperText="Contact support to change"
                  />
                </Grid>
                <Grid item xs={12}>
                  <Button
                    variant="contained"
                    onClick={handleProfileUpdate}
                    disabled={saving}
                  >
                    {saving ? 'Saving...' : 'Save Changes'}
                  </Button>
                </Grid>
                {/* Documents (Tier 3 only) */}
                {((merchant?.tier || ownerData.tier) === 'Tier 3') && (
                  <Grid item xs={12} sx={{ mt: 2 }}>
                    <Divider sx={{ my: 2 }} />
                    <Typography variant="h6" sx={{ mb: 1 }}>Uploaded Documents</Typography>
                    {Array.isArray((merchant as any)?.documents) && (merchant as any).documents.length > 0 ? (
                      (merchant as any).documents.map((doc: any, idx: number) => {
                        // doc may be string URL or object { name, url }
                        const name = typeof doc === 'string' ? `Document ${idx + 1}` : doc.name || `Document ${idx + 1}`;
                        const url = typeof doc === 'string' ? doc : doc.url || '';
                        return (
                          <Box key={idx} sx={{ display: 'flex', alignItems: 'center', gap: 2, mb: 1 }}>
                            <Typography variant="body2">{name}</Typography>
                            {url ? (
                              <Button size="small" variant="outlined" component="a" href={url} target="_blank" rel="noreferrer">View</Button>
                            ) : (
                              <Typography variant="caption" color="text.secondary">No link available</Typography>
                            )}
                          </Box>
                        );
                      })
                    ) : (
                      <Typography variant="body2" color="text.secondary">No documents uploaded yet.</Typography>
                    )}
                  </Grid>
                )}
              </Grid>
            </Box>
          </TabPanel>

          {/* Bank Details Tab */}
          <TabPanel value={tabValue} index={2}>
            <Box sx={{ px: 3 }}>
              <Alert severity="warning" sx={{ mb: 3 }}>
                Ensure your bank details are correct. All settlements will be sent to this account.
              </Alert>

              <Grid container spacing={3}>
                {/* If we have saved bank info and not in edit mode, show a read-only summary with a Replace button */}
                {!editBank && bankData.bankName && bankData.accountNumber ? (
                  <>
                    <Grid item xs={12}>
                      <Box sx={{ p: 2, borderRadius: 1, border: '1px solid', borderColor: 'divider' }}>
                        <Typography variant="subtitle2">Current Payout Account</Typography>
                        <Box sx={{ mt: 1 }}>
                          <Typography variant="body1">{bankData.accountName || '—'}</Typography>
                          <Typography variant="body2" color="text.secondary">{bankData.bankName} • {bankData.accountNumber}</Typography>
                        </Box>
                        <Box sx={{ mt: 2 }}>
                          <Typography variant="caption" color="text.secondary">If you add a new account it will replace this one.</Typography>
                        </Box>
                      </Box>
                    </Grid>
                    <Grid item xs={12}>
                      <Box sx={{ display: 'flex', gap: 2 }}>
                        <Button variant="outlined" onClick={() => { setEditBank(true); }}>
                          Replace Bank Account
                        </Button>
                      </Box>
                    </Grid>
                  </>
                ) : (
                  // Edit mode: show form to add/replace bank details
                  <>
                    <Grid item xs={12} sm={6}>
                      {/* Autocomplete for bank selection so user can scroll available banks */}
                      <Autocomplete
                        freeSolo
                        options={banks}
                        value={bankData.bankName}
                        onChange={(_e, val) => setBankData({ ...bankData, bankName: (val as string) || '' })}
                        renderInput={(params) => (
                          <TextField {...params} label="Bank Name" fullWidth />
                        )}
                      />
                    </Grid>
                    <Grid item xs={12} sm={6}>
                      <Box sx={{ display: 'flex', gap: 1, alignItems: 'center' }}>
                        <TextField
                          fullWidth
                          label="Account Number"
                          value={bankData.accountNumber}
                          onChange={(e) => setBankData({ ...bankData, accountNumber: e.target.value })}
                          onBlur={async () => {
                            const acc = (bankData.accountNumber || '').replace(/\s+/g, '');
                            if (acc.length >= 6) {
                              try {
                                const resolved = await resolveAccountName(bankData.bankName || '', acc);
                                if (resolved) {
                                  setBankData((prev) => ({ ...prev, accountName: prev.accountName || resolved }));
                                  toast.success('Account name resolved');
                                } else {
                                  toast('Could not resolve account details automatically', { icon: 'ℹ️' });
                                }
                              } catch (err) {
                                console.error('Auto-resolve error:', err);
                              }
                            }
                          }}
                          helperText="Enter the account number; it will auto-resolve on blur"
                        />
                        <Button variant="outlined" onClick={async () => {
                          const acc = (bankData.accountNumber || '').replace(/\s+/g, '');
                          if (acc.length >= 6) {
                            const resolved = await resolveAccountName(bankData.bankName || '', acc);
                            if (resolved) {
                              setBankData((prev) => ({ ...prev, accountName: prev.accountName || resolved }));
                              toast.success('Account name resolved');
                            } else {
                              toast('Could not resolve account details automatically', { icon: 'ℹ️' });
                            }
                          } else {
                            toast('Enter a valid account number to resolve', { icon: 'ℹ️' });
                          }
                        }} sx={{ whiteSpace: 'nowrap' }}>Resolve</Button>
                      </Box>
                    </Grid>
                    <Grid item xs={12} sm={6}>
                      <TextField
                        fullWidth
                        label="Account Name"
                        value={bankData.accountName}
                        onChange={(e) => setBankData({ ...bankData, accountName: e.target.value })}
                        helperText="Account name can be auto-resolved from account number"
                      />
                    </Grid>
                    <Grid item xs={12} sm={6}>
                      <TextField
                        fullWidth
                        label="Account Type"
                        value={bankData.accountType}
                        onChange={(e) => setBankData({ ...bankData, accountType: e.target.value })}
                        helperText="e.g., Savings, Current"
                      />
                    </Grid>

                    <Grid item xs={12} sx={{ display: 'flex', gap: 2 }}>
                      <Button variant="outlined" onClick={() => { setEditBank(false); /* cancel edit */ }} disabled={saving}>Cancel</Button>
                      <Button variant="contained" onClick={async () => { await handleBankUpdate(); setEditBank(false); }} disabled={saving}>
                        {saving ? 'Saving...' : 'Replace Account'}
                      </Button>
                    </Grid>
                  </>
                )}
              </Grid>
            </Box>
          </TabPanel>

          {/* API Keys Tab */}
          <TabPanel value={tabValue} index={3}>
            <Box sx={{ px: 3 }}>
              <Alert severity="info" sx={{ mb: 3 }}>
                API keys are used to integrate Adna with your applications. Keep them secure!
              </Alert>
              <Typography variant="body1" color="text.secondary">
                API key management will be available soon. Contact support if you need access now.
              </Typography>
            </Box>
          </TabPanel>

          {/* Security Tab */}
          <TabPanel value={tabValue} index={4}>
            <Box sx={{ px: 3 }}>
              <Alert severity="info" sx={{ mb: 3 }}>
                Manage your account security settings
              </Alert>
              <Typography variant="body1" color="text.secondary">
                Security settings and two-factor authentication will be available soon.
              </Typography>
            </Box>
          </TabPanel>
        </Paper>
        {/* Email change dialog */}
        <Dialog open={emailDialogOpen} onClose={closeEmailDialog} fullWidth maxWidth="sm">
          <DialogTitle>Change Email</DialogTitle>
          <DialogContent>
            {isPasswordProvider ? (
              <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2, mt: 1 }}>
                <TextField label="New Email" fullWidth value={newEmail} onChange={(e) => setNewEmail(e.target.value)} />
                <TextField label="Current Password" type="password" fullWidth value={currentPassword} onChange={(e) => setCurrentPassword(e.target.value)} />
              </Box>
            ) : (
              <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2, mt: 1 }}>
                <Typography variant="body2" color="text.secondary">
                  Your account uses an external provider (Google). To change your email, please submit a request and our support team will assist with account reassociation.
                </Typography>
                <TextField label="Requested New Email" fullWidth value={newEmail} onChange={(e) => setNewEmail(e.target.value)} />
                <TextField label="Reason / Notes (optional)" fullWidth value={requestReason} onChange={(e) => setRequestReason(e.target.value)} />
              </Box>
            )}
          </DialogContent>
          <DialogActions>
            <Button onClick={closeEmailDialog} disabled={saving}>Cancel</Button>
            <Button variant="contained" onClick={handleEmailChangeSubmit} disabled={saving || !newEmail}>
              {saving ? 'Processing...' : isPasswordProvider ? 'Change Email' : 'Request Change'}
            </Button>
          </DialogActions>
        </Dialog>
      </Container>
    </DashboardLayout>
  );
};

export default SettingsPage;
