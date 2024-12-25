import React from 'react';
import { CreditCard, Plus } from 'lucide-react';
import { Button } from '../ui/Button';

export function PaymentMethods() {
  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <div>
          <h3 className="text-lg font-semibold text-white mb-1">Payment Methods</h3>
          <p className="text-sm text-gray-400">Manage your payment methods</p>
        </div>
        <Button className="flex items-center gap-2">
          <Plus className="w-4 h-4" />
          Add Method
        </Button>
      </div>

      <div className="space-y-3">
        <div className="flex items-center justify-between p-4 bg-white/5 rounded-lg border border-white/10">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-lg bg-primary/10 flex items-center justify-center">
              <CreditCard className="w-5 h-5 text-primary" />
            </div>
            <div>
              <h4 className="text-white font-medium">•••• 4242</h4>
              <p className="text-sm text-gray-400">Expires 12/24</p>
            </div>
          </div>
          <div className="flex items-center gap-2">
            <span className="px-2 py-1 text-xs rounded-full bg-primary/10 text-primary">Default</span>
            <Button variant="secondary" size="sm">Edit</Button>
          </div>
        </div>
      </div>
    </div>
  );
}