# Custom Domain Setup for adna.app

## ✅ Deployment Status

Your web app is now live at:
- **Primary URL**: https://adna-faa82.web.app
- **Alternative URL**: https://adna-faa82.firebaseapp.com

Both default domains are now working! 🎉

---

## 🌐 Setting Up Custom Domain: adna.app

### Step 1: Go to Firebase Console

1. Open: https://console.firebase.google.com/project/adna-faa82/hosting/sites
2. Click on your hosting site
3. Click **"Add custom domain"** button

### Step 2: Enter Your Domain

1. Enter: `adna.app` (without www)
2. Click **"Continue"**
3. Firebase will show you verification steps

### Step 3: Verify Domain Ownership

Firebase will provide you with a **TXT record** to add to your DNS provider. It will look like:

```
Type: TXT
Name: @ (or leave blank)
Value: firebase-site-verification=xxxxxxxxxxxxxxxxxxxxxx
TTL: Auto or 3600
```

**Go to your domain registrar** (where you purchased adna.app) and add this TXT record.

### Step 4: Add DNS Records for Firebase Hosting

After verification, Firebase will give you **A records** to point your domain to Firebase:

```
Type: A
Name: @ (or leave blank)
Value: 151.101.1.195
TTL: Auto or 3600

Type: A
Name: @ (or leave blank)
Value: 151.101.65.195
TTL: Auto or 3600
```

**Add BOTH A records** to your DNS settings.

### Step 5: (Optional) Add www Subdomain

If you want `www.adna.app` to work as well:

1. In Firebase Console, click **"Add another domain"**
2. Enter: `www.adna.app`
3. Add the A records Firebase provides (same as above)
4. Or add a CNAME record:

```
Type: CNAME
Name: www
Value: adna-faa82.web.app
TTL: Auto or 3600
```

### Step 6: Wait for DNS Propagation

- DNS changes can take **15 minutes to 48 hours** to propagate globally
- Usually takes **1-2 hours** for most users
- Firebase will automatically provision SSL certificate once DNS is verified

---

## 🔒 SSL Certificate

Firebase Hosting automatically provisions and renews SSL certificates for your custom domain. Once DNS is set up:

- ✅ **Free SSL certificate** from Let's Encrypt
- ✅ **Auto-renewal** every 90 days
- ✅ **HTTPS enforced** by default
- ✅ **HTTP automatically redirects** to HTTPS

---

## 📋 Common DNS Providers

### Namecheap
1. Log in to Namecheap
2. Go to Domain List → Manage → Advanced DNS
3. Add the TXT record for verification
4. Add the A records
5. Click **"Save All Changes"**

### GoDaddy
1. Log in to GoDaddy
2. Go to My Products → DNS
3. Click **"Add"** for each record
4. Add TXT record first, then A records
5. Click **"Save"**

### Cloudflare
1. Log in to Cloudflare
2. Select your domain
3. Go to DNS settings
4. Add TXT record (orange cloud OFF)
5. Add A records (orange cloud OFF for Firebase)
6. **Important**: Disable Cloudflare proxy for Firebase Hosting

### Google Domains
1. Log in to Google Domains
2. Go to DNS
3. Scroll to Custom resource records
4. Add TXT record
5. Add both A records
6. Click **"Add"**

---

## ✅ Verification Checklist

Once you've added the DNS records, check:

1. **TXT Record Verification**:
   ```bash
   nslookup -type=TXT adna.app
   ```
   Should show your Firebase verification string

2. **A Record Verification**:
   ```bash
   nslookup adna.app
   ```
   Should show: `151.101.1.195` and `151.101.65.195`

3. **Wait for Firebase**:
   - Firebase Console will show **"Connected"** status
   - SSL certificate will be provisioned automatically
   - Status will change from **"Pending"** → **"Connected"**

---

## 🚀 After Setup

Once your custom domain is connected:

- ✅ Your app will be accessible at: `https://adna.app`
- ✅ Your app will be accessible at: `https://www.adna.app` (if you added it)
- ✅ Old URLs will still work: `https://adna-faa82.web.app`
- ✅ All traffic automatically uses HTTPS
- ✅ HTTP requests automatically redirect to HTTPS

---

## 🔧 Troubleshooting

### "Domain verification failed"
- Make sure TXT record is added correctly
- Wait 15-30 minutes for DNS propagation
- Try removing and re-adding the TXT record

### "Unable to connect to domain"
- Verify both A records are added
- Check that there are no conflicting CNAME records
- Wait up to 24 hours for DNS propagation

### "SSL certificate pending"
- This is normal - can take up to 24 hours
- Firebase provisions certificate after DNS is verified
- Don't worry if it shows "Pending" for a while

### "Too many redirects"
- If using Cloudflare, disable the orange cloud (proxy)
- Or set SSL mode to "Full" in Cloudflare

---

## 📞 Need Help?

If you encounter issues:

1. **Check Firebase Console** for detailed error messages
2. **Use DNS checker tools**:
   - https://dnschecker.org
   - Enter your domain and check TXT/A records globally
3. **Firebase Support**: https://firebase.google.com/support

---

## 🎉 Summary

✅ **Build completed**: Production bundle created in `adna-web/dist`
✅ **Firebase Hosting configured**: `firebase.json` updated with hosting rules
✅ **Deployed to Firebase**: https://adna-faa82.web.app
✅ **Next step**: Add DNS records to connect adna.app

Your web app is now live and ready to use! Just need to point your custom domain to Firebase Hosting by adding the DNS records in your domain registrar's control panel.
