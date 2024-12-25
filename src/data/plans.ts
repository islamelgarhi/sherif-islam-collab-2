import type { PricingPlan } from '@/types/pricing';

export const PLANS: PricingPlan[] = [
  {
    id: 'starter',
    name: 'Starter',
    price: 9.99,
    billing: 'monthly',
    description: 'Perfect for small businesses just getting started.',
    features: [
      'Up to 100 review monitoring',
      'Basic response templates',
      'Email alerts',
      'Standard support',
      'Single platform integration'
    ]
  },
  {
    id: 'professional',
    name: 'Professional',
    price: 19.99,
    billing: 'monthly',
    description: 'Ideal for growing businesses with active review management.',
    features: [
      'Up to 500 review monitoring',
      'AI-powered response suggestions',
      'Priority review alerts',
      'Priority support',
      'Multi-platform integration',
      'Review removal assistance',
      'Monthly performance reports'
    ],
    popular: true
  },
  {
    id: 'enterprise',
    name: 'Enterprise',
    price: 29.99,
    billing: 'monthly',
    description: 'Complete solution for large businesses and franchises.',
    features: [
      'Unlimited review monitoring',
      'Advanced AI analysis',
      'Real-time alerts',
      'Dedicated account manager',
      'All platform integrations',
      'Priority review removal',
      'Custom API access',
      'White-label reports',
      'Team collaboration tools',
      'Custom training sessions'
    ]
  }
];