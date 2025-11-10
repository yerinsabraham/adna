import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Box,
  Container,
  Typography,
  Accordion,
  AccordionSummary,
  AccordionDetails,
  IconButton,
} from '@mui/material';
import { ExpandMore, ArrowBack, Home } from '@mui/icons-material';

const FAQPage: React.FC = () => {
  const navigate = useNavigate();
  const [expanded, setExpanded] = useState<string | false>(false);

  const handleChange = (panel: string) => (_event: React.SyntheticEvent, isExpanded: boolean) => {
    setExpanded(isExpanded ? panel : false);
  };

  const faqs = [
    {
      question: 'How long does settlement take?',
      answer: 'Typically within one hour of payment confirmation. Our automated system processes settlements quickly to ensure your funds reach your business account as fast as possible.',
    },
    {
      question: 'What payment methods are supported?',
      answer: 'Bitcoin (BTC), Tether (USDT), and USD Coin (USDC). We support the most popular and stable digital assets to give your customers flexibility.',
    },
    {
      question: 'What are your fees?',
      answer: '2.5% per transaction. No setup fees, no monthly fees, no hidden costs. You only pay when you receive payments.',
    },
    {
      question: 'Do I need technical knowledge?',
      answer: 'No. The platform handles all technical aspects. Simply create payment requests, share with customers, and receive settlements. Our dashboard makes everything simple.',
    },
    {
      question: 'Is this compliant?',
      answer: 'Yes. We operate in partnership with licensed providers and follow regulatory guidelines. All transactions are secure and compliant with Nigerian regulations.',
    },
    {
      question: 'How do I get started?',
      answer: 'Click "Get Started" or "Request Access", complete the registration form, submit your KYC documents, and once approved, you can start accepting payments immediately.',
    },
    {
      question: 'What are the transaction limits?',
      answer: 'Transaction limits depend on your merchant tier. After KYC approval, you will be assigned daily and monthly limits based on your business needs.',
    },
    {
      question: 'Can I integrate Adna with my website?',
      answer: 'Yes. We provide API documentation and integration tools. Contact our support team for technical assistance with integration.',
    },
  ];

  return (
    <Box sx={{ minHeight: '80vh', py: 8, bgcolor: 'background.default' }}>
      <Container maxWidth="md">
        <Box sx={{ display: 'flex', alignItems: 'center', mb: 3, gap: 2 }}>
          <IconButton onClick={() => navigate(-1)} sx={{ color: '#0f4e9d' }}>
            <ArrowBack />
          </IconButton>
          <IconButton onClick={() => navigate('/')} sx={{ color: '#0f4e9d' }}>
            <Home />
          </IconButton>
          <Typography variant="h4" fontWeight={800} sx={{ color: '#0a3d7a' }}>
            Frequently Asked Questions
          </Typography>
        </Box>
        
        <Typography variant="body1" color="text.secondary" sx={{ mb: 4 }}>
          Find answers to common questions about Adna payment platform.
        </Typography>

        <Box>
          {faqs.map((faq, index) => (
            <Accordion
              key={index}
              expanded={expanded === `panel${index}`}
              onChange={handleChange(`panel${index}`)}
              sx={{
                mb: 2,
                borderRadius: 2,
                '&:before': { display: 'none' },
                boxShadow: '0 2px 8px rgba(0,0,0,0.08)',
              }}
            >
              <AccordionSummary
                expandIcon={<ExpandMore />}
                sx={{
                  '& .MuiAccordionSummary-content': {
                    my: 2,
                  },
                }}
              >
                <Typography variant="h6" fontWeight={600} sx={{ color: '#0a3d7a' }}>
                  {faq.question}
                </Typography>
              </AccordionSummary>
              <AccordionDetails>
                <Typography variant="body1" color="text.secondary">
                  {faq.answer}
                </Typography>
              </AccordionDetails>
            </Accordion>
          ))}
        </Box>

        <Box sx={{ mt: 6, p: 4, bgcolor: '#f7fbff', borderRadius: 3, textAlign: 'center' }}>
          <Typography variant="h6" fontWeight={700} sx={{ mb: 1 }}>
            Still have questions?
          </Typography>
          <Typography variant="body1" color="text.secondary" sx={{ mb: 2 }}>
            Contact our support team and we'll be happy to help.
          </Typography>
          <Box sx={{ display: 'flex', gap: 2, justifyContent: 'center' }}>
            <IconButton
              onClick={() => navigate('/contact')}
              sx={{
                bgcolor: '#0f4e9d',
                color: 'white',
                px: 3,
                py: 1,
                borderRadius: 2,
                '&:hover': {
                  bgcolor: '#0a3d7a',
                },
              }}
            >
              <Typography variant="button" sx={{ textTransform: 'none' }}>
                Contact Us
              </Typography>
            </IconButton>
          </Box>
        </Box>
      </Container>
    </Box>
  );
};

export default FAQPage;
