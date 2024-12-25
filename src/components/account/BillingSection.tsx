import React from 'react';
import { CreditCard, Package, CheckCircle } from 'lucide-react';
import { Button } from '../ui/Button';
import { PlanDetails } from './PlanDetails';
import { PaymentMethods } from './PaymentMethods';
import { BillingHistory } from './BillingHistory';

export function BillingSection() {
  return (
    <div className="space-y-8">
      {/* Current Plan */}
      <PlanDetails />

      {/* Payment Methods */}
      <PaymentMethods />

      {/* Billing History */}
      <BillingHistory />
    </div>
  );
}